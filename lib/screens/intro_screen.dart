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

  // 색상 팔레트 (InputScreen과 동일하게 맞춤)
  final Color _bgStart = const Color(0xFF08080A);
  final Color _bgEnd = const Color(0xFF101018);
  final Color _accentColor = const Color(0xFF00E676); // Neon Teal

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoggingIn = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final user = await authService.signInWithGoogle();
      
      if (user != null) {
        await SajuApi.syncUser(
          uid: user.uid,
          email: user.email ?? "",
        );

        if (!mounted) return;
        
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgStart, _bgEnd], // 배경 톤 통일
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // 1. 로고 애니메이션 (운)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accentColor.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
                color: Colors.white.withOpacity(0.02), // 유리 느낌 추가
              ),
              child: Center(
                child: Text(
                  '運',
                  style: TextStyle(
                    fontSize: 56, 
                    color: _accentColor, 
                    fontWeight: FontWeight.w300,
                    shadows: [
                      Shadow(color: _accentColor.withOpacity(0.8), blurRadius: 15)
                    ]
                  ),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 0.95, end: 1.05, duration: 2500.ms, curve: Curves.easeInOutSine)
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),

            const SizedBox(height: 60),

            // 2. 타이틀 (Cinzel 폰트 유지 - 신비감)
            Text(
              'SAJU.OS',
              style: GoogleFonts.cinzel(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 8.0,
              ),
            ).animate().fadeIn(duration: 1000.ms).moveY(begin: 20, end: 0),

            const SizedBox(height: 10),

            Text(
              'ELEMENTAL BLUEPRINT',
              style: GoogleFonts.inter(
                color: Colors.white38,
                letterSpacing: 4.0,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 1000.ms),

            const Spacer(flex: 3),

            // 3. 로그인/시작 버튼 섹션
            if (_isLoggingIn)
              Column(
                children: [
                  CircularProgressIndicator(color: _accentColor),
                  const SizedBox(height: 20),
                  Text("Synchronizing...", style: TextStyle(color: _accentColor, fontFamily: 'monospace')),
                ],
              )
            else ...[
              // 구글 로그인 버튼 (유리 스타일 적용)
              _buildGlassButton(
                icon: Icons.g_mobiledata_rounded, // or Icons.login
                label: 'CONTINUE WITH GOOGLE', 
                onTap: _handleGoogleSignIn,
                isPrimary: true,
              ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 16),
              
              // 게스트 로그인
              _buildGlassButton(
                icon: Icons.person_outline,
                label: 'ENTER AS GUEST', 
                onTap: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const InputScreen()),
                  );
                },
                isPrimary: false,
              ).animate().fadeIn(delay: 1000.ms).moveY(begin: 20, end: 0),
            ],
            
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  // InputScreen의 버튼 스타일과 통일 (Glassmorphism)
  Widget _buildGlassButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          // Primary면 약간의 틴트, 아니면 투명
          color: isPrimary ? _accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16), // 둥글기 통일
          border: Border.all(
            color: isPrimary ? _accentColor.withOpacity(0.5) : Colors.white12,
            width: 1.5,
          ),
          boxShadow: isPrimary 
            ? [BoxShadow(color: _accentColor.withOpacity(0.15), blurRadius: 20)] 
            : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isPrimary ? _accentColor : Colors.white54, 
              size: 20
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isPrimary ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}