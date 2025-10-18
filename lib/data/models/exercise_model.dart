import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String gifUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.gifUrl,
  });

  factory ExerciseModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExerciseModel(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      bodyPart: data['bodyPart'] ?? '',
      target: data['target'] ?? '',
      equipment: data['equipment'] ?? '',
      gifUrl: data['gifUrl'] ?? '',
    );
  }
}