import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  
  fb.User? get currentUser => _firebaseAuth.currentUser;
 
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      
      
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      
      throw Exception('Terjadi kesalahan saat login.');
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
            
    } on fb.FirebaseAuthException catch (e) {
      
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mendaftar.');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout.');
    }
  }

  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'operation-not-allowed':
         return 'Metode login ini tidak diizinkan.';
      default:
        return 'Terjadi kesalahan autentikasi: $errorCode';
    }
  }
}
