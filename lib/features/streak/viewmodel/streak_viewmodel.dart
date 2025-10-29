import 'package:flutter/material.dart';
import '../../../data/models/workout_session_model.dart'; 
import '../../../data/repositories/workout_repository.dart'; 

enum StreakState { Idle, Loading, Success, Error }

class StreakViewModel extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();

  StreakState _state = StreakState.Idle;
  StreakState get state => _state;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  DateTime? _lastWorkoutDate;
  DateTime? get lastWorkoutDate => _lastWorkoutDate;

  List<DateTime> _workoutDates = [];
  List<DateTime> get workoutDates => _workoutDates;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(StreakState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> fetchAllStreakData() async {
    _setState(StreakState.Loading);
    try {
      final streakData = await _repository.getUserStreakData();
      _currentStreak = streakData['currentStreak'] ?? 0;
      _lastWorkoutDate = streakData['lastWorkoutDate'];

      final List<WorkoutSessionModel> sessions = await _repository.getWorkoutSessions();
      _workoutDates = sessions
          .map((session) => DateTime(
                session.startTime.year,
                session.startTime.month,
                session.startTime.day,
              ))
          .toSet() 
          .toList();

      _setState(StreakState.Success);
      print("[StreakViewModel] Fetched streak: $_currentStreak, LastDate: $_lastWorkoutDate");
      print("[StreakViewModel] Fetched workout dates count: ${_workoutDates.length}");
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print("[StreakViewModel] Error fetching all streak data: $_errorMessage");
      _setState(StreakState.Error);
    }
  }
}

