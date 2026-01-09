import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'input_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 애니메이션
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF45A29E), width: 2),
              ),
              child: const Center(
                child: Text(
                  '運',
                  style: TextStyle(fontSize: 40, color: Color(0xFF45A29E)),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: const Color(0xFF66FCF1))
            .scaleXY(begin: 0.9, end: 1.0, duration: 1500.ms, curve: Curves.easeInOut)
            .then()
            .scaleXY(begin: 1.0, end: 0.9, duration: 1500.ms, curve: Curves.easeInOut),

            const SizedBox(height: 40),

            // 타이틀
            Text(
              'SAJU',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                letterSpacing: 8.0,
              ),
            ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),

            Text(
              'ELEMENTAL BLUEPRINT',
              style: GoogleFonts.inter(
                color: const Color(0xFF45A29E),
                letterSpacing: 4.0,
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

            const SizedBox(height: 60),

            // 시작 버튼
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => const InputScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF45A29E)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text(
                'BEGIN JOURNEY',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}