import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/models/workout_model.dart'; 

enum ViewState { Idle, Loading, Success, Error }

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final StorageRepository _storageRepository = StorageRepository();

  ViewState _state = ViewState.Idle;
  ViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> saveWorkout({
    required String exerciseName,
    required int reps,
    required int sets,
    required double weight,
    File? mediaFile,
  }) async {
     final user = FirebaseAuth.instance.currentUser;
     if (user == null) {
       _errorMessage = "Pengguna tidak terautentikasi.";
       _setState(ViewState.Error);
       return;
     }
     final String userId = user.uid;
     _setState(ViewState.Loading);

     try {
       String? mediaUrl;
       if (mediaFile != null) {
         final String filePath = 'videos/$userId/${DateTime.now().millisecondsSinceEpoch}';
         mediaUrl = await _storageRepository.uploadFile(mediaFile, filePath);
       }
       final newWorkout = WorkoutModel(
         userId: userId,
         exerciseName: exerciseName,
         reps: reps,
         sets: sets, 
         weight: weight,
         mediaUrl: mediaUrl,
         createdAt: DateTime.now(),
       );
       await _workoutRepository.addWorkout(newWorkout);
       _setState(ViewState.Success);
     } catch (e) {
       _errorMessage = e.toString();
       _setState(ViewState.Error);
     }
  }


  
  
  Future<bool> saveWorkoutSession({
      required List<Map<String, dynamic>> setsData,
      required Duration duration,
      required DateTime sessionStartTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = "Pengguna tidak terautentikasi.";
      _setState(ViewState.Error);
      return false; 
    }
    final String userId = user.uid;

    _setState(ViewState.Loading);

    try {
      await _workoutRepository.addWorkoutSession(
        userId: userId,
        setsData: setsData,
        duration: duration,
        sessionStartTime: sessionStartTime,
      );
      _setState(ViewState.Success);
      return true; 
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.Error);
      return false; 
    } finally {
       
       await Future.delayed(const Duration(milliseconds: 500));
       if (state != ViewState.Error) { 
          _setState(ViewState.Idle);
       }
    }
  }
   void resetErrorState() {
      if (_state == ViewState.Error) {
         _setState(ViewState.Idle);
      }
   }
}
