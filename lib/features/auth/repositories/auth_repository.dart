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
      
      throw Exception('There is an error while logging in');
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
      throw Exception('There is an error while registering');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('There is an error while logging out');
    }
  }

  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email not registered';
      case 'wrong-password':
        return 'Wrong Password';
      case 'invalid-email':
        return 'Invalid email formal';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'password is too weak';
      case 'operation-not-allowed':
         return 'Operation not allowed';
      default:
        return 'There is an authentication error: $errorCode';
    }
  }
}
