import 'package:flutter/material.dart';
import '../../../data/models/exercise_model.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Latihan
            Center(
              child: Image.network(
                exercise.imageUrl,
                height: 250, // Atur tinggi gambar
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator())
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                     height: 250,
                     child: Center(child: Icon(Icons.broken_image, size: 50))
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Detail Latihan
            _buildDetailRow('Target Otot:', exercise.target ?? 'N/A'),
            _buildDetailRow('Alat:', exercise.equipment ?? 'N/A'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Instruksi
            Text(
              'Instruksi:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            // Tampilkan instruksi sebagai daftar bernomor
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.instructions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(exercise.instructions[index])),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
