import 'exercise_model.dart';
import 'set_entry_model.dart';

class WorkoutGroup {
  final ExerciseModel exercise;
  final List<SetEntry> sets = []; 

  WorkoutGroup({required this.exercise}) {
    sets.add(SetEntry());
  }
}
