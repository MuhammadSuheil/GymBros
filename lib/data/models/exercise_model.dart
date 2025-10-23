import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? equipment;
  final String? target;
  final List<String> instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.equipment,
    this.target,
    required this.instructions,
  });

  factory ExerciseModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String finalImageUrl = '';

    const String baseUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

    final String exerciseName = data['name'] ?? '';

    if (exerciseName.isNotEmpty) {
      final String folderName = exerciseName.replaceAll(' ', '_').replaceAll('/', '_');
      final String imagePath = '$folderName/0.jpg';
      finalImageUrl = baseUrl + imagePath;
    }
    
    final List<dynamic> instructionsData = data['instructions'] as List<dynamic>? ?? [];
    final List<String> parsedInstructions = instructionsData.map((item) => item.toString()).toList();

    return ExerciseModel(
      id: data['id'] ?? doc.id,
      name: exerciseName,
      imageUrl: finalImageUrl,
      equipment: data['equipment'] ?? 'N/A',
      target: (data['primaryMuscles'] as List<dynamic>).isNotEmpty 
              ? (data['primaryMuscles'] as List<dynamic>)[0].toString() 
              : 'N/A',
              instructions: parsedInstructions,
    );
  }
}

