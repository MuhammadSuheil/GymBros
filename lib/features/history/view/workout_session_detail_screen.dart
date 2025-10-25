import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/workout_session_model.dart'; 

class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSessionModel session;

  const WorkoutSessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMM yyyy', 'en_US').format(session.startTime);
    final formattedTime = DateFormat('HH:mm', 'en_US').format(session.startTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Sesi - $formattedDate'), 
      ),
      body: ListView( 
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date:', formattedDate),
                  _buildDetailRow('Start Time:', formattedTime),
                  _buildDetailRow('Duration:', session.formattedDuration),
                  if (session.bodyWeight != null) 
                    _buildDetailRow('Body Weight:', '${session.bodyWeight} kg'),
                  if (session.notes != null && session.notes!.isNotEmpty) 
                    _buildDetailRow('Notes:', session.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sets Performed (${session.sets.length})',
             style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: const [
                 Expanded(flex: 4, child: Text('Exercise', style: TextStyle(fontWeight: FontWeight.bold))),
                 Expanded(flex: 1, child: Text('Set', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                 Expanded(flex: 2, child: Text('Weight (kg)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                 Expanded(flex: 1, child: Text('Reps', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
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
                   padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 4, child: Text(exerciseName, style: TextStyle(decoration: isCompleted ? null : TextDecoration.lineThrough, color: isCompleted ? null : Colors.grey))),
                        Expanded(flex: 1, child: Text(setNumber.toString(), textAlign: TextAlign.center, style: TextStyle(color: isCompleted ? null : Colors.grey))),
                        Expanded(flex: 2, child: Text(weight.toString(), textAlign: TextAlign.right, style: TextStyle(color: isCompleted ? null : Colors.grey))),
                        Expanded(flex: 1, child: Text(reps.toString(), textAlign: TextAlign.center, style: TextStyle(color: isCompleted ? null : Colors.grey))),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
