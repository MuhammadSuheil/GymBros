import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_session_model.dart'; 
// Import 'collection' jika Anda masih menggunakan extension methods
// import 'package:collection/collection.dart'; 

class WorkoutRepository {
  final CollectionReference _sessionsCollection =
      FirebaseFirestore.instance.collection('workout_sessions');
  final CollectionReference _profilesCollection =
      FirebaseFirestore.instance.collection('user_profiles');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> addWorkoutSession({
    required String userId,
    required List<Map<String, dynamic>> setsData,
    required Duration duration,
    required DateTime sessionStartTime,
    String? notes,
    double? bodyWeight,
  }) async {
    // ... (Logika addWorkoutSession yang sudah benar) ...
    if (setsData.isEmpty) { throw Exception('No set data to save.'); }

    final profileDocRef = _profilesCollection.doc(userId);
    final DateTime sessionEndTime = DateTime.now();
    final newSessionDocRef = _sessionsCollection.doc();

    print("[WorkoutRepository] Received parameters to save:");
    print("  Notes: '$notes'");
    print("  BodyWeight: $bodyWeight");

    await FirebaseFirestore.instance.runTransaction((transaction) async {
       DocumentSnapshot profileSnapshot = await transaction.get(profileDocRef);
       int currentStreak = 0;
       int longestStreak = 0; 
       DateTime? lastWorkoutDate;

       if (profileSnapshot.exists) {
         final data = profileSnapshot.data() as Map<String, dynamic>;
         currentStreak = data['currentStreak'] ?? 0;
         longestStreak = data['longestStreak'] ?? 0; // Baca longest streak
         lastWorkoutDate = (data['lastWorkoutDate'] as Timestamp?)?.toDate();
       }

       int newStreak = 0;
       DateTime todayStart = DateTime(sessionStartTime.year, sessionStartTime.month, sessionStartTime.day);
       DateTime? lastWorkoutDayStart;
       if (lastWorkoutDate != null) { lastWorkoutDayStart = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day); }

       if (lastWorkoutDayStart != null) {
         int differenceInDays = todayStart.difference(lastWorkoutDayStart).inDays;
         if (differenceInDays == 0) { newStreak = currentStreak; }
         else if (differenceInDays >= 1 && differenceInDays <= 4) { newStreak = currentStreak + 1; }
         else { newStreak = 1; }
       } else { newStreak = 1; }
       print("[Streak Logic] Calculated newStreak: $newStreak");

       transaction.set(newSessionDocRef, {
         'userId': userId,
         'startTime': Timestamp.fromDate(sessionStartTime),
         'endTime': Timestamp.fromDate(sessionEndTime),
         'durationSeconds': duration.inSeconds,
         'sets': setsData,
         'notes': notes,
         'bodyWeight': bodyWeight,
       });
       print("[Transaction] Set session data completed with notes: '$notes', bodyWeight: $bodyWeight.");

       bool shouldUpdateProfile = !profileSnapshot.exists || (lastWorkoutDayStart != null && todayStart.isAfter(lastWorkoutDayStart)) || lastWorkoutDayStart == null;
       if (shouldUpdateProfile) {
          int newLongestStreak = (newStreak > longestStreak) ? newStreak : longestStreak; // Hitung longest streak baru
          Map<String, dynamic> profileUpdateData = {
             'userId': userId,
             'lastWorkoutDate': Timestamp.fromDate(sessionStartTime),
             'currentStreak': newStreak,
             'longestStreak': newLongestStreak, // Simpan longest streak
             'email': _firebaseAuth.currentUser?.email
          };
          if (!profileSnapshot.exists) { transaction.set(profileDocRef, profileUpdateData); }
          else { transaction.update(profileDocRef, profileUpdateData); }
          print("[Transaction] Profile update scheduled.");
       } else { print("[Transaction] Profile update skipped."); }

    }).catchError((error, stackTrace) {
       print("===================================");
       print("!!! Firestore Transaction Failed !!!");
       print("Error Type: ${error.runtimeType}");
       print("Error: $error");
       print("Stack Trace:\n$stackTrace");
       print("===================================");
       throw Exception('Transaction Failed: $error');
    });
  }

  Future<List<WorkoutSessionModel>> getWorkoutSessions() async {
     final user = _firebaseAuth.currentUser;
     if (user == null) { print("[WorkoutRepository] User not logged in..."); return []; }
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
     } catch (e) { print('[WorkoutRepository] Error fetching sessions: $e'); throw Exception('Error fetching Workout History'); }
   }

  // --- PASTIKAN FUNGSI INI MENGEMBALIKAN 'longestStreak' ---
  Future<Map<String, dynamic>> getUserStreakData() async {
     final user = _firebaseAuth.currentUser;
     if (user == null) return {'currentStreak': 0, 'lastWorkoutDate': null, 'longestStreak': 0};

     try {
       final profileDoc = await _profilesCollection.doc(user.uid).get();
       if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;
          DateTime? lastWorkoutDate = (data['lastWorkoutDate'] as Timestamp?)?.toDate();
          int currentStreak = data['currentStreak'] ?? 0;
          int longestStreak = data['longestStreak'] ?? 0; // Ambil longest streak

          if (lastWorkoutDate != null) {
             DateTime todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
             DateTime lastWorkoutDayStart = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
             int differenceInDays = todayStart.difference(lastWorkoutDayStart).inDays;
             if (differenceInDays > 4) { currentStreak = 0; }
          }
          return {
            'currentStreak': currentStreak, 
            'lastWorkoutDate': lastWorkoutDate,
            'longestStreak': longestStreak, // Kembalikan longest streak
          };
       } else {
          return {'currentStreak': 0, 'lastWorkoutDate': null, 'longestStreak': 0};
       }
     } catch (e) {
        print("[Streak Logic] Error fetching streak data: $e");
        return {'currentStreak': 0, 'lastWorkoutDate': null, 'longestStreak': 0};
     }
  }
}

