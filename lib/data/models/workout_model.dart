import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String? id; 
  final String userId; 
  final String exerciseName; 
  final int reps; 
  final int sets; 
  final double weight; 
  final String? mediaUrl; 
  final DateTime createdAt; 

  WorkoutModel({
    this.id,
    required this.userId,
    required this.exerciseName,
    required this.reps,
    required this.sets,
    required this.weight,
    this.mediaUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'reps': reps,
      'sets': sets,
      'weight': weight,
      'mediaUrl': mediaUrl,
      'createdAt': Timestamp.fromDate(createdAt), 
    };
  }

  factory WorkoutModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id, 
      userId: data['userId'],
      exerciseName: data['exerciseName'],
      reps: data['reps'],
      sets: data['sets'],
      weight: (data['weight'] as num).toDouble(), 
      mediaUrl: data['mediaUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(), 
    );
  }
}
