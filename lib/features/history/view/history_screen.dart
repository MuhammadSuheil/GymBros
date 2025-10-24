import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import '../viewmodel/history_viewmodel.dart';
import '../../../data/models/workout_session_model.dart'; 
import 'workout_session_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<HistoryViewModel>().fetchHistory(),
          ),
        ],
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == HistoryState.Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.state == HistoryState.Error) {
            return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Failed loading history: ${viewModel.errorMessage}'),),);
          }
          if (viewModel.sessions.isEmpty) {
             return const Center(child: Text('There are no workout history yet', style: TextStyle(fontSize: 18, color: Colors.grey),),);
          }


          return ListView.builder(
            itemCount: viewModel.sessions.length,
            itemBuilder: (context, index) {
              final WorkoutSessionModel session = viewModel.sessions[index];
              final formattedDate = DateFormat('EEEE, d MMM yyyy', 'id_US').format(session.startTime);
              final formattedTime = DateFormat('HH:mm', 'id_US').format(session.startTime);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    formattedDate, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding( 
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Start: $formattedTime'),
                         Text('Duration: ${session.formattedDuration}'),
                         const SizedBox(height: 6),
                         Text(
                           'Workout: ${session.exercisesSummary}',
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                           style: TextStyle(color: Colors.grey.shade600),
                         ),
                       ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey), 
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
            },
          );
        },
      ),
    );
  }
}

