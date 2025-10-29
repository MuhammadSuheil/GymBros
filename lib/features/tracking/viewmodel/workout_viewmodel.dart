import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../data/repositories/storage_repository.dart';

enum ViewState { Idle, Loading, Success, Error }

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final StorageRepository _storageRepository = StorageRepository(); 

  ViewState _state = ViewState.Idle;
  ViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(ViewState newState) {
    if (_state != newState) { 
       _state = newState;
       notifyListeners();
    }
  }

  Future<bool> saveWorkoutSession({
      required List<Map<String, dynamic>> setsData,
      required Duration duration,
      required DateTime sessionStartTime,
      String? notes,
      double? bodyWeight,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = "User not authenticated";
      _setState(ViewState.Error);
      return false;
    }
    final String userId = user.uid;
    
    print("[WorkoutViewModel] Received parameters:");
    print("  Notes: '$notes'");
    print("  BodyWeight: $bodyWeight");
    
    _setState(ViewState.Loading);
    bool success = false; 
    try {
      await _workoutRepository.addWorkoutSession(
        userId: userId,
        setsData: setsData,
        duration: duration,
        sessionStartTime: sessionStartTime,
        notes: notes, 
        bodyWeight: bodyWeight,
      );
      _setState(ViewState.Success); 
      success = true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', ''); 
      print("[WorkoutViewModel] Save session failed: $_errorMessage"); 
      _setState(ViewState.Error);
      success = false;
    } finally {
       await Future.delayed(const Duration(milliseconds: 500));
       if (_state == ViewState.Success || _state == ViewState.Idle) {
         _setState(ViewState.Idle);
       }
    }
     return success; 
  }

   void resetErrorState() {
      if (_state == ViewState.Error) {
         _setState(ViewState.Idle);
      }
   }
}

