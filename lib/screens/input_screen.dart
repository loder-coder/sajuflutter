import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../api/saju_api.dart';
import '../services/auth_service.dart';
import 'result_screen.dart';
import 'intro_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  
  double _longitude = 127.0; // 기본값 (백엔드가 보정하므로 크게 중요치 않음)
  double _latitude = 37.5;
  String _timezone = 'Asia/Seoul';
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  // 생년월일 날짜 선택
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF45A29E),
              onPrimary: Colors.black,
              surface: Color(0xFF1F2833),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  // 태어난 시간 선택
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context, 
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _timeController.text = DateFormat('HH:mm').format(
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute)
        );
      });
    }
  }

  // 지역 검색 (UI 자동완성용)
  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final results = await SajuApi.searchLocation(query);
      setState(() => _searchResults = results);
    } catch (e) {
      print("Location search error: $e");
    }
  }

  // 로그아웃 처리
  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const IntroScreen()),
      (route) => false,
    );
  }

  // 사주 분석 실행
  Future<void> _analyze() async {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일과 시간을 모두 입력해주세요!')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    
    setState(() => _isLoading = true);
    try {
      // [중요] birthPlace에 도시 이름을 넘겨줘야 백엔드 Google Maps가 작동함
      final result = await SajuApi.calculateSaju(
        birthDate: _dateController.text,
        birthTime: _timeController.text,
        timezone: _timezone,
        longitude: _longitude,
        latitude: _latitude,
        birthPlace: _locationController.text, // 도시 이름 전송!
        userId: user?.uid, 
        includeAnalysis: true,
      );

      if (!mounted) return;
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ResultScreen(sajuModel: result))
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ENTER ORIGIN', 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF45A29E)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1F2833),
                  title: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
                  content: const Text('로그아웃 하시겠습니까?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text('취소', style: TextStyle(color: Colors.white38))
                    ),
                    TextButton(
                      onPressed: _handleLogout, 
                      child: const Text('확인', style: TextStyle(color: Color(0xFF66FCF1)))
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField(
              controller: _dateController,
              label: 'Birth Date',
              icon: Icons.calendar_today,
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _timeController,
              label: 'Birth Time',
              icon: Icons.access_time,
              onTap: _selectTime,
            ),
            const SizedBox(height: 20),
            
            _buildTextField(
              controller: _locationController,
              label: 'City Search',
              icon: Icons.search,
              hint: 'e.g. Seoul, Nanterre',
              onChanged: _onSearchChanged,
            ),
            
            // 검색 결과 리스트
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2833), 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: _searchResults.map((item) => ListTile(
                    dense: true,
                    title: Text(
                      item['display_name'], 
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        _locationController.text = item['display_name'].split(',')[0];
                        _longitude = double.parse(item['lon']);
                        _latitude = double.parse(item['lat']);
                        _searchResults = [];
                        // 타임존은 백엔드에서 Google Maps로 정확히 찾으므로 여기선 대충 넘겨도 됨
                        _timezone = 'UTC'; 
                      });
                    },
                  )).toList(),
                ),
              ),
            
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45A29E),
                  disabledBackgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black) 
                  : const Text(
                      'REVEAL MY ENERGY', 
                      style: TextStyle(
                        color: Colors.black, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5,
                        fontSize: 16
                      )
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    VoidCallback? onTap,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        labelStyle: const TextStyle(color: Color(0xFF45A29E)),
        suffixIcon: Icon(icon, color: const Color(0xFF45A29E)),
        filled: true,
        fillColor: const Color(0xFF1F2833).withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1))
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF45A29E))
        ),
      ),
    );
  }
}