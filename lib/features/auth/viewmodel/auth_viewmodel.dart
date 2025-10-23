import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

enum AuthState { Idle, Loading, Success, Error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthState _state = AuthState.Idle;
  AuthState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  fb.User? get currentUser => _authRepository.currentUser;

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
       print("[AuthViewModel] Notifying listeners for state: $_state");
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print("[AuthViewModel] Attempting sign in for: $email");
    _setState(AuthState.Loading);
    bool success = false; 
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("[AuthViewModel] Sign in successful for: $email");
      success = true; 
      _setState(AuthState.Idle);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print("[AuthViewModel] Sign in failed: $_errorMessage");
      _setState(AuthState.Error);
      success = false; 
    }
    return success; 
  }
  
  Future<bool> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    print("[AuthViewModel] Attempting registration for: $email");
    _setState(AuthState.Loading);
    bool success = false;
    try {
      await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
       print("[AuthViewModel] Registration successful for: $email");
       success = true;
       _setState(AuthState.Idle);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print("[AuthViewModel] Registration failed: $_errorMessage");
      _setState(AuthState.Error);
      success = false;
    }
     return success;
  }
  


   void resetErrorState() {
      if (_state == AuthState.Error) {
         _setState(AuthState.Idle);
      }
   }

  Future<void> signOut() async {
    print("[AuthViewModel] Attempting sign out...");
    _setState(AuthState.Loading);
    try {
      await _authRepository.signOut();
       print("[AuthViewModel] Sign out successful.");
       _setState(AuthState.Idle);
       
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
       print("[AuthViewModel] Sign out failed: $_errorMessage");
       _setState(AuthState.Error);
    }
  }
}

