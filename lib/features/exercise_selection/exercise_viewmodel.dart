import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/exercise_repository.dart';

class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _repository = ExerciseRepository();

  List<ExerciseModel> exercises = [];
  bool isLoading = false;
  bool hasMoreData = true; 
  DocumentSnapshot? _lastDocument;

  ExerciseViewModel() {
    fetchInitialExercises();
  }

  Future<void> fetchInitialExercises() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getExercisesPaginated();
      exercises = result['exercises'];
      _lastDocument = result['lastDocument'];
      hasMoreData = exercises.length == 20; 
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreExercises() async {
    if (isLoading || !hasMoreData) return;

    isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getExercisesPaginated(lastDocument: _lastDocument);
      final newExercises = result['exercises'];
      
      exercises.addAll(newExercises); 
      _lastDocument = result['lastDocument'];
      hasMoreData = newExercises.length == 20;
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }
}
