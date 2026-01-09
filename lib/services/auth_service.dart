import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 유저 로그인 상태 모니터링 스트림
  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 구글 로그인 실행 로직
  Future<User?> signInWithGoogle() async {
    try {
      // 1. 구글 로그인 팝업 호출
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. 구글 인증 정보 획득
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Firebase용 자격 증명 생성
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase 로그인 진행
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("❌ 구글 로그인 에러 발생: $e");
      return null;
    }
  }

  // 로그아웃 처리
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("❌ 로그아웃 에러 발생: $e");
    }
  }
}