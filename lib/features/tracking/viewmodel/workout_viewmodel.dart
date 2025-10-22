import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../../../data/repositories/workout_repository.dart';
import '../../../../data/repositories/storage_repository.dart';
import '../../../../data/models/workout_model.dart';

enum ViewState { idle, loading, success, error }

class WorkoutViewModel extends ChangeNotifier{
    final WorkoutRepository _workoutRepository = WorkoutRepository();
    final StorageRepository _storageRepository = StorageRepository();

    ViewState _state = ViewState.idle;
    String _errorMessage = '';

    ViewState get state => _state;
    String get errorMessage => _errorMessage;
    
    void _setState(ViewState newState) {
    _state = newState;
    notifyListeners(); 
  }
  Future<void> saveWorkout ({
    required String exerciseName,
    required int reps,
    required int sets,
    required double weight,
    File? mediaFile,

  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = "Pengguna tidak terautentikasi.";
      _setState(ViewState.error);
      return;
    }
    final String userId = user.uid;
    _setState(ViewState.loading);

    try{
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
    }catch(e){
        _errorMessage = e.toString();
        _setState(ViewState.error);
    }
  }
}
