import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../api/saju_api.dart';
import 'input_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _isLoggingIn = false;

  // 구글 로그인 처리 함수
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoggingIn = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final user = await authService.signInWithGoogle();
      
      if (user != null) {
        // 1. 내 백엔드 서버에 유저 정보 동기화 (DB 저장)
        await SajuApi.syncUser(
          uid: user.uid,
          email: user.email ?? "",
        );

        if (!mounted) return;
        
        // 2. 로그인 성공 시 입력 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InputScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0C10), Color(0xFF1F2833)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 애니메이션
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF45A29E), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66FCF1).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  '運',
                  style: TextStyle(fontSize: 48, color: Color(0xFF66FCF1), fontWeight: FontWeight.w300),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 3000.ms, color: const Color(0xFF66FCF1).withOpacity(0.5))
            .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms, curve: Curves.easeInOutSine)
            .then()
            .scaleXY(begin: 1.05, end: 0.95, duration: 2000.ms, curve: Curves.easeInOutSine),

            const SizedBox(height: 50),

            // 타이틀
            Text(
              'SAJU',
              style: GoogleFonts.cinzel(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 12.0,
              ),
            ).animate().fadeIn(duration: 1000.ms).moveY(begin: 30, end: 0),

            Text(
              'ELEMENTAL BLUEPRINT',
              style: GoogleFonts.inter(
                color: const Color(0xFF45A29E),
                letterSpacing: 6.0,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 1000.ms),

            const SizedBox(height: 100),

            // 로그인/시작 버튼 섹션
            if (_isLoggingIn)
              const CircularProgressIndicator(color: Color(0xFF66FCF1))
            else ...[
              // 구글 로그인 버튼
              _buildSocialButton(
                icon: Icons.login, 
                label: 'CONTINUE WITH GOOGLE', 
                onTap: _handleGoogleSignIn,
                isPrimary: true,
              ).animate().fadeIn(delay: 800.ms),
              
              const SizedBox(height: 20),
              
              // 비로그인 시작 버튼
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const InputScreen()),
                  );
                },
                child: Text(
                  'CONTINUE AS GUEST',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF45A29E).withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: const Color(0xFF45A29E).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF66FCF1), size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}