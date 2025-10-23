import 'package:flutter/material.dart';
import '../../../data/models/workout_session_model.dart';
import '../../../data/repositories/workout_repository.dart';

enum HistoryState { Idle, Loading, Success, Error }

class HistoryViewModel extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();

  HistoryState _state = HistoryState.Idle;
  HistoryState get state => _state;

  List<WorkoutSessionModel> _sessions = [];
  List<WorkoutSessionModel> get sessions => _sessions;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _setState(HistoryState.Loading);
    try {
      _sessions = await _repository.getWorkoutSessions();
      _setState(HistoryState.Success);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(HistoryState.Error);
    }
  }
}
