import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/workout_session_model.dart'; 
import '../../../core/constants/app_colors.dart';

class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSessionModel session;

  const WorkoutSessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMM yyyy', 'en_US').format(session.startTime);
    final formattedTime = DateFormat('HH:mm', 'en_US').format(session.startTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session Detail - $formattedDate'), 
      ),
      body: ListView( 
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session Summary',
                  style: TextStyle(color: AppColors.onPrimary, fontSize: 28, fontWeight: FontWeight.w700),),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date:', formattedDate),
                  _buildDetailRow('Start Time:', formattedTime),
                  _buildDetailRow('Duration:', session.formattedDuration),
                  if (session.bodyWeight != null) 
                    _buildDetailRow('Body Weight:', '${session.bodyWeight} kg'),
                  if (session.notes != null && session.notes!.isNotEmpty) 
                    _buildDetailRow('Notes:', session.notes!),
                    SizedBox(height: 12,)
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sets Performed (${session.sets.length})',
             style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700)
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: const [
                 Expanded(flex: 4, child: Text('Exercise', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary))),
                 Expanded(flex: 1, child: Text('Set', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary))),
                 Expanded(flex: 2, child: Text('Weight (kg)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary))),
                 Expanded(flex: 1, child: Text('Reps', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimary))),
               ],
            ),
          ),
          const Divider(),
          ListView.separated(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             itemCount: session.sets.length,
             itemBuilder: (context, index) {
                final set = session.sets[index] as Map<String, dynamic>; 
                final exerciseName = set['exerciseName'] ?? 'N/A';
                final setNumber = set['setNumber'] ?? index + 1; 
                final weight = set['weight'] ?? '-';
                final reps = set['reps'] ?? '-';
                final isCompleted = set['isCompleted'] ?? false; 
                return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 4, child: Text(exerciseName, style: TextStyle(decoration: isCompleted ? null : TextDecoration.lineThrough, color:AppColors.onPrimary))),
                        Expanded(flex: 1, child: Text(setNumber.toString(), textAlign: TextAlign.center, style: TextStyle(color:AppColors.onPrimary))),
                        Expanded(flex: 2, child: Text(weight.toString(), textAlign: TextAlign.right, style: TextStyle(color:AppColors.onPrimary))),
                        Expanded(flex: 1, child: Text(reps.toString(), textAlign: TextAlign.center, style: TextStyle(color:AppColors.onPrimary))),
                      ],
                   ),
                );
             },
             separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
           )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onPrimary)),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: TextStyle(color: AppColors.onPrimary),)),
        ],
      ),
    );
  }
}
