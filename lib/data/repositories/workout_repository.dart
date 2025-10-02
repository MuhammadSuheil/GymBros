import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutRepository {
  final CollectionReference _workoutsCollection =
      FirebaseFirestore.instance.collection('workouts');

  Future<void> addWorkout(WorkoutModel workout) async {
    try {
      await _workoutsCollection.add(workout.toMap());
    } catch (e) {

      print('Error adding workout to Firestore: $e');
      throw Exception('Error adding workout data');
    }
  }

  // Nanti isi lagi
}
