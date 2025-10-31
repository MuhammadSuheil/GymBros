import 'package:flutter/material.dart';
import '../../../data/models/exercise_model.dart';
import 'package:gymbros/core/constants/app_colors.dart'; 

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
            Center(
              child: Image.network(
                exercise.imageUrl,
                height: 250, 
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
            _buildDetailRow('Target Muscle:', exercise.target ?? 'N/A'),
            _buildDetailRow('Equipment:', exercise.equipment ?? 'N/A'),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            Text(
              'Instructions',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: AppColors.onPrimary),
              
            ),
            const SizedBox(height: 10),
            
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
                      Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary)),
                      Expanded(child: Text(exercise.instructions[index], style: const TextStyle(color: AppColors.onPrimary))),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onPrimary)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.onPrimary))),
        ],
      ),
    );
  }
}
