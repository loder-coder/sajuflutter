import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/intro_screen.dart';

void main() {
  runApp(const SajuApp());
}

class SajuApp extends StatelessWidget {
  const SajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elemental Blueprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 전체적인 다크 테마 설정
        scaffoldBackgroundColor: const Color(0xFF0B0C10), // 먹색 (Ink Black)
        primaryColor: const Color(0xFF45A29E), // 옥색 (Jade)
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF45A29E),
          secondary: Color(0xFF66FCF1), // 밝은 옥색 (Accent)
          surface: Color(0xFF1F2833),   // 카드 배경색
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFFC5C6C7), // 금색/회색 (Gold/Silver)
          ),
        ),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}