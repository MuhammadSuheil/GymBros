import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../viewmodel/streak_viewmodel.dart';

class StreakScreen extends StatefulWidget { 
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Streak'),
        actions: [
           IconButton(
             icon: const Icon(Icons.refresh),
             tooltip: 'Reload Streak',
             onPressed: () => context.read<StreakViewModel>().fetchStreakData(),
           ),
         ],
      ),
      body: Consumer<StreakViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == StreakState.Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.state == StreakState.Error) {
             return Center(child: Text('Error loading streak: ${viewModel.errorMessage}'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Icon(Icons.local_fire_department_rounded, size: 100, color: Colors.orangeAccent),
                 const SizedBox(height: 20),
                 Text(
                   '${viewModel.currentStreak}',
                   style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                 ),
                 Text(
                   viewModel.currentStreak == 1 ? 'Day Streak!' : 'Day Streak!',
                   style: const TextStyle(fontSize: 24, color: Colors.grey),
                 ),
                 const SizedBox(height: 30),
                 if (viewModel.lastWorkoutDate != null)
                   Text(
                     'Last workout: ${DateFormat('EEEE, d MMM yyyy', 'en_US').format(viewModel.lastWorkoutDate!)}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                   )
                 else
                    const Text(
                     'Start your first workout to begin the streak!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
