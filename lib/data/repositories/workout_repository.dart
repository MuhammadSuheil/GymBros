import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart'; 

class WorkoutRepository {
  final CollectionReference _workoutsCollection =
      FirebaseFirestore.instance.collection('workouts');

  final CollectionReference _sessionsCollection =
      FirebaseFirestore.instance.collection('workout_sessions');

  Future<void> addWorkout(WorkoutModel workout) async {
    try {
      await _workoutsCollection.add(workout.toMap());
    } catch (e) {
      print('Error adding workout: $e');
      throw Exception('Gagal menyimpan data workout.');
    }
  }

  Future<void> addWorkoutSession({
    required String userId,
    required List<Map<String, dynamic>> setsData,
    required Duration duration,
    required DateTime sessionStartTime, 
  }) async {
    if (setsData.isEmpty) {
      throw Exception('Tidak ada data set untuk disimpan.');
    }

    try {

      await _sessionsCollection.add({
        'userId': userId,
        'startTime': Timestamp.fromDate(sessionStartTime), 
        'endTime': Timestamp.now(), 
        'durationSeconds': duration.inSeconds, 
        'sets': setsData, 

      });
    } catch (e) {
      print('Error adding workout session: $e');
      throw Exception('Gagal menyimpan sesi latihan.');
    }
  }
}

