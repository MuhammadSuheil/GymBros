import 'package:flutter/material.dart';
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

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(StreakState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> fetchStreakData() async {
    _setState(StreakState.Loading);
    try {
      final data = await _repository.getUserStreakData();
      _currentStreak = data['currentStreak'] ?? 0;
      _lastWorkoutDate = data['lastWorkoutDate'];
      _setState(StreakState.Success);
       print("[StreakViewModel] Fetched streak data: Streak=$_currentStreak, LastDate=$_lastWorkoutDate");
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
       print("[StreakViewModel] Error fetching streak: $_errorMessage");
      _setState(StreakState.Error);
    }
  }
}
