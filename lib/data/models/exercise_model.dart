import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? equipment;
  final String? target;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.equipment,
    this.target,
  });

  factory ExerciseModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // ===================================================================
    // PERBAIKAN FINAL: Menggunakan Base URL yang BENAR!
    // ===================================================================
    String finalImageUrl = '';
    // Ganti 'dist' menjadi 'exercises'
    const String baseUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

    final String exerciseName = data['name'] ?? '';

    if (exerciseName.isNotEmpty) {
      // Logika ini sudah benar: mengganti spasi dan '/' dengan '_'
      final String folderName = exerciseName.replaceAll(' ', '_').replaceAll('/', '_');
      final String imagePath = '$folderName/0.jpg';
      finalImageUrl = baseUrl + imagePath;
    }
    // ===================================================================

    return ExerciseModel(
      id: data['id'] ?? doc.id,
      name: exerciseName,
      imageUrl: finalImageUrl,
      equipment: data['equipment'] ?? 'N/A',
      // 'primaryMuscles' adalah list, kita ambil yang pertama saja
      target: (data['primaryMuscles'] as List<dynamic>).isNotEmpty 
              ? (data['primaryMuscles'] as List<dynamic>)[0].toString() 
              : 'N/A',
    );
  }
}

