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
  
  double _longitude = 127.0; // 기본값 서울
  String _timezone = 'Asia/Seoul';
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  // 생년월일 날짜 선택 (DatePicker)
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

  // 태어난 시간 선택 (TimePicker)
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

  // 지역 검색 (SajuApi 연동)
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

  // 로그아웃 처리 및 화면 전환
  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (!mounted) return;
    
    // 모든 화면 스택을 비우고 인트로 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const IntroScreen()),
      (route) => false,
    );
  }

  // 사주 분석 실행 (UID 포함하여 서버에 전송)
  Future<void> _analyze() async {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일과 시간을 모두 입력해주세요!')),
      );
      return;
    }

    // 현재 로그인된 Firebase 유저 정보 확인
    final user = FirebaseAuth.instance.currentUser;
    
    setState(() => _isLoading = true);
    try {
      final result = await SajuApi.calculateSaju(
        birthDate: _dateController.text,
        birthTime: _timeController.text,
        timezone: _timezone,
        longitude: _longitude,
        userId: user?.uid, // UID를 함께 보내야 Railway DB에 기록이 남습니다.
        includeAnalysis: true,
      );

      if (!mounted) return;
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ResultScreen(data: result))
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 에러 발생: $e')),
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
          // 로그아웃 버튼 (우측 상단 아이콘)
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
            // 날짜 입력 필드
            _buildTextField(
              controller: _dateController,
              label: 'Birth Date',
              icon: Icons.calendar_today,
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),
            // 시간 입력 필드
            _buildTextField(
              controller: _timeController,
              label: 'Birth Time',
              icon: Icons.access_time,
              onTap: _selectTime,
            ),
            const SizedBox(height: 20),
            
            // 지역 검색 필드
            _buildTextField(
              controller: _locationController,
              label: 'City Search',
              icon: Icons.search,
              hint: 'e.g. Seoul, New York',
              onChanged: _onSearchChanged,
            ),
            
            // 지역 검색 결과 목록 (자동완성)
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
                        _searchResults = [];
                        // 경도에 따라 타임존 자동 추측 (서울 근처 120~135도)
                        _timezone = (_longitude > 120 && _longitude < 135) ? 'Asia/Seoul' : 'America/New_York';
                      });
                    },
                  )).toList(),
                ),
              ),
            
            const SizedBox(height: 60),
            // 분석 결과 확인 버튼
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

  // 공통 텍스트 필드 빌더
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