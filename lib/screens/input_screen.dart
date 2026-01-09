
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

class _InputScreenState extends State<InputScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  
  // 데이터 저장 변수
  double _longitude = 127.0;
  double _latitude = 37.5;
  String _timezone = 'Asia/Seoul';
  
  // UI 상태 변수
  bool _isLoading = false;
  int _currentStep = 0;
  List<dynamic> _searchResults = [];
  
  // 애니메이션용
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800)
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // --- 기능 로직 (기존 유지) ---

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => _buildThemePicker(context, child),
    );
    if (picked != null) {
      setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
      _nextStep(); // 선택하면 바로 다음 단계로 자연스럽게 이동 유도
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context, 
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => _buildThemePicker(context, child),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _timeController.text = DateFormat('HH:mm').format(
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute)
        );
      });
      _nextStep();
    }
  }

  Widget _buildThemePicker(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Teal
          onPrimary: Colors.black,
          surface: Color(0xFF1E1E2C),
          onSurface: Colors.white,
        ),
        dialogBackgroundColor: const Color(0xFF1E1E2C),
      ),
      child: child!,
    );
  }

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

  void _selectLocation(Map<String, dynamic> item) {
    setState(() {
      _locationController.text = item['display_name'].split(',')[0];
      _longitude = double.parse(item['lon']);
      _latitude = double.parse(item['lat']);
      _searchResults = [];
      // 타임존은 백엔드에서 처리
    });
    FocusScope.of(context).unfocus(); // 키보드 내리기
    // _nextStep(); // 지도는 사용자가 확인 버튼 누르게 둠 (검색 결과 확인 때문)
  }

  Future<void> _analyze() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() => _isLoading = true);
    
    try {
      final result = await SajuApi.calculateSaju(
        birthDate: _dateController.text,
        birthTime: _timeController.text,
        timezone: _timezone,
        longitude: _longitude,
        latitude: _latitude,
        birthPlace: _locationController.text,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const IntroScreen()),
      (route) => false,
    );
  }

  // --- 네비게이션 로직 ---

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutCubic
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutCubic
      );
      setState(() => _currentStep--);
    }
  }

  // --- 화면 구성 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep Ink Black
      resizeToAvoidBottomInset: false, // 키보드 올라와도 배경 유지
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 
          ? IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white54), onPressed: _prevStep)
          : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white30),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: Stack(
        children: [
          // 배경: 은은한 효과
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF08080A), Color(0xFF101018)],
                ),
              ),
            ),
          ),
          
          // 메인 컨텐츠 (PageView)
          Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // 스와이프 막음 (버튼으로만 이동)
                  children: [
                    _buildStepDate(),
                    _buildStepTime(),
                    _buildStepLocation(),
                    _buildStepReview(),
                  ],
                ),
              ),
            ],
          ),

          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF00E676)),
                    const SizedBox(height: 20),
                    Text(
                      "Aligning Stars...",
                      style: TextStyle(
                        color: const Color(0xFF00E676).withOpacity(0.8),
                        fontFamily: 'monospace',
                        letterSpacing: 2
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 상단 진행 바
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF00E676) : Colors.white10,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive 
                  ? [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.5), blurRadius: 6)] 
                  : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 각 단계별 페이지 ---

  Widget _buildStepDate() {
    return _buildStepContainer(
      title: "WHEN DID YOUR\nJOURNEY BEGIN?",
      subtitle: "Select your date of birth",
      icon: Icons.calendar_month_outlined,
      content: _buildGlassButton(
        text: _dateController.text.isEmpty ? "YYYY - MM - DD" : _dateController.text,
        onTap: _selectDate,
        isActive: _dateController.text.isNotEmpty,
      ),
    );
  }

  Widget _buildStepTime() {
    return _buildStepContainer(
      title: "AT WHAT MOMENT\nDID YOU ARRIVE?",
      subtitle: "Select your time of birth",
      icon: Icons.access_time,
      content: _buildGlassButton(
        text: _timeController.text.isEmpty ? "HH : MM" : _timeController.text,
        onTap: _selectTime,
        isActive: _timeController.text.isNotEmpty,
      ),
    );
  }

  Widget _buildStepLocation() {
    return _buildStepContainer(
      title: "WHERE IS YOUR\nORIGIN POINT?",
      subtitle: "Search for your birth city",
      icon: Icons.public,
      content: Column(
        children: [
          TextField(
            controller: _locationController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "e.g. Seoul, Nanterre",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676))),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
            onChanged: _onSearchChanged,
          ),
          
          // 검색 결과 리스트 (떠있는 느낌)
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return ListTile(
                    title: Text(item['display_name'], style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _selectLocation(item),
                  );
                },
              ),
            ),
            
          const SizedBox(height: 24),
          if (_locationController.text.isNotEmpty && _searchResults.isEmpty)
            _buildNextButton("CONFIRM LOCATION", _nextStep),
        ],
      ),
    );
  }

  Widget _buildStepReview() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fingerprint, size: 60, color: Color(0xFF00E676)),
          const SizedBox(height: 30),
          const Text(
            "IDENTITY VERIFIED",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          const Text(
            "Ready to decode your blueprint.",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          
          _buildReviewItem("DATE", _dateController.text),
          _buildReviewItem("TIME", _timeController.text),
          _buildReviewItem("ORIGIN", _locationController.text),
          
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: const Color(0xFF00E676).withOpacity(0.5),
              ),
              child: const Text(
                "REVEAL DESTINY",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 공통 위젯 빌더 ---

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF00E676)),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
            const SizedBox(height: 48),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({required String text, required VoidCallback onTap, required bool isActive}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E676).withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF00E676) : Colors.white12,
            width: 1.5
          ),
          boxShadow: isActive ? [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.2), blurRadius: 15)] : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? const Color(0xFF00E676) : Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, letterSpacing: 1.5)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}