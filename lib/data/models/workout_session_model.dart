import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSessionModel {
  final String id; 
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final List<dynamic> sets; 
  final String? notes; 
  final double? bodyWeight; 

  WorkoutSessionModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.sets,
    this.notes,
    this.bodyWeight,
  });

  factory WorkoutSessionModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutSessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationSeconds: data['durationSeconds'] ?? 0,
      sets: data['sets'] as List<dynamic>? ?? [],
      notes: data['notes'] as String?, 
      bodyWeight: (data['bodyWeight'] as num?)?.toDouble(), 
    );
  }


  String get formattedDuration {
     final duration = Duration(seconds: durationSeconds);
     String twoDigits(int n) => n.toString().padLeft(2, '0');
     final hours = twoDigits(duration.inHours);
     final minutes = twoDigits(duration.inMinutes.remainder(60));
     final seconds = twoDigits(duration.inSeconds.remainder(60));
     if (duration.inHours > 0) { return "$hours:$minutes:$seconds"; }
     return "$minutes:$seconds";
  }

   String get exercisesSummary {
      if (sets.isEmpty) return 'No exercises';
      final exerciseNames = sets.map((set) => set['exerciseName'] as String? ?? 'N/A')
                                 .toSet()
                                 .take(3)
                                 .join(', ');
      return exerciseNames;
   }
}

