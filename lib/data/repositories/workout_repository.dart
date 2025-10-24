import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/workout_session_model.dart'; 

class WorkoutRepository {
  final CollectionReference _sessionsCollection = FirebaseFirestore.instance.collection('workout_sessions');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> addWorkoutSession({
    required String userId,
    required List<Map<String, dynamic>> setsData,
    required Duration duration,
    required DateTime sessionStartTime,
  }) async {
    if (setsData.isEmpty) { throw Exception('There is not set to be saved'); }
    try {
      await _sessionsCollection.add({
        'userId': userId,
        'startTime': Timestamp.fromDate(sessionStartTime),
        'endTime': Timestamp.now(),
        'durationSeconds': duration.inSeconds,
        'sets': setsData,
      });
    } catch (e) { print('Error adding workout session: $e'); throw Exception('Error saving workout session');}
  }

  Future<List<WorkoutSessionModel>> getWorkoutSessions() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      print("[WorkoutRepository] User not logged in, cannot fetch history.");
      return []; 
    }
    final String userId = user.uid;
    try {
      print("[WorkoutRepository] Fetching sessions for user: $userId"); 
      QuerySnapshot snapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId) 
          .orderBy('startTime', descending: true) 
          .get();
      print("[WorkoutRepository] Found ${snapshot.docs.length} sessions."); 

      return snapshot.docs
          .map((doc) => WorkoutSessionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('[WorkoutRepository] Error fetching workout sessions: $e');
      throw Exception('Error fetching Workout History');
    }
  }
}

