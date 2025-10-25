import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; 
import 'package:intl/intl.dart'; 
import '../../tracking/view/workout_tracking_screen.dart';
import '../../history/viewmodel/history_viewmodel.dart';
import '../../../data/models/workout_session_model.dart';
import '../../history/view/workout_session_detail_screen.dart';

class HomeScreen extends StatefulWidget { 
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Guest';
    final historyViewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GymBros'),
        automaticallyImplyLeading: false,
      ),
      
      body: ListView(
        padding: const EdgeInsets.all(20.0), 
        children: [
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            userEmail, 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          Text(
            'Feeling good today?', 
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.fitness_center),
            label: const Text('Start a New Workout'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), 
              textStyle: const TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutTrackingScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Workouts', 
             style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildRecentHistory(historyViewModel),
        ],
      ),
    );
  }

  Widget _buildRecentHistory(HistoryViewModel viewModel) {
     if (viewModel.state == HistoryState.Loading) {
       return const Center(child: Padding(
         padding: EdgeInsets.all(20.0),
         child: CircularProgressIndicator(),
       ));
     }
     if (viewModel.state == HistoryState.Error) {
       return Center(child: Text('Failed to load history: ${viewModel.errorMessage}'));
     }
     if (viewModel.sessions.isEmpty) {
       return const Center(child: Text('No recent workouts found.'));
     }
     final recentSessions = viewModel.sessions.take(3).toList();

     return Column(
       children: recentSessions.map((session) {
          final formattedDate = DateFormat('EEE, d MMM yyyy', 'en_US').format(session.startTime); 
          return Card(
             margin: const EdgeInsets.symmetric(vertical: 6),
             child: ListTile(
               title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.w500)),
               subtitle: Text(
                 'Duration: ${session.formattedDuration} | Exercises: ${session.exercisesSummary}',
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
               ),
               trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
               onTap: () {
                  Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => WorkoutSessionDetailScreen(session: session),
                     ),
                   );
               },
             ),
           );
       }).toList(),
     );
  }
}
