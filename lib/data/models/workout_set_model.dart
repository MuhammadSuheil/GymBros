import 'exercise_model.dart';
import 'package:flutter/material.dart';

class WorkoutSet {
  final ExerciseModel exercise; 
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool isCompleted = false; 

  WorkoutSet({required this.exercise});

}
