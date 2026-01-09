import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase 핵심 패키지
import 'package:provider/provider.dart'; // 상태 관리 패키지
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/intro_screen.dart';

void main() async {
  // 1. 플러터 엔진 초기화 확인 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Firebase 초기화 (구글 로그인 및 클라우드 기능을 위해 필수)
  await Firebase.initializeApp();
  
  runApp(
    // 3. AuthService를 앱 전체에서 접근 가능하도록 Provider로 감싸기
    Provider<AuthService>(
      create: (_) => AuthService(),
      child: const SajuApp(),
    ),
  );
}

class SajuApp extends StatelessWidget {
  const SajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elemental Blueprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // 다크 모드 기반의 세련된 UI 색상 설정
        scaffoldBackgroundColor: const Color(0xFF0B0C10), // 깊은 먹색
        primaryColor: const Color(0xFF45A29E), // 옥색 강조
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF45A29E),
          secondary: Color(0xFF66FCF1),
          surface: Color(0xFF1F2833),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFFC5C6C7),
          ),
        ),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}