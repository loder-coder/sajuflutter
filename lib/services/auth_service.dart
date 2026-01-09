import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/saju_api.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      // 1. 구글 팝업
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. 인증 획득
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. 파이어베이스 자격 증명
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. 파이어베이스 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // 5. [핵심] 내 서버(Railway)랑 동기화 - 여기서 DB에 유저가 생성됨
      if (user != null) {
        await SajuApi.syncUser(
          uid: user.uid,
          email: user.email ?? "",
          provider: 'google',
        );
      }

      return user;
    } catch (e) {
      print("❌ 구글 로그인/동기화 에러: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}