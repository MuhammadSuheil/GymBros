import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodel/history_viewmodel.dart';
import '../../../data/models/workout_session_model.dart';
import 'workout_session_detail_screen.dart';
import '../../../core/constants/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // --- Fungsi untuk mengambil data ---
  Future<void> _fetchHistory() async {
    // Gunakan context.read() di dalam fungsi
    // 'listen: false' (via read) aman di luar build
    await Provider.of<HistoryViewModel>(context, listen: false).fetchHistory();
  }

  @override
  void initState() {
    super.initState();
    // Ambil data saat layar pertama kali dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        // Hapus tombol refresh di AppBar karena kita pakai Pull-to-Refresh
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          // --- Bungkus ListView dengan RefreshIndicator ---
          return RefreshIndicator(
            onRefresh: _fetchHistory, // Panggil _fetchHistory saat ditarik
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            // --- Akhir Pembungkusan ---
            child: Builder( // Gunakan Builder agar state bisa dievaluasi
              builder: (context) {
                // 1. Tampilkan Loading
                if (viewModel.state == HistoryState.Loading && viewModel.sessions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. Tampilkan Error
                if (viewModel.state == HistoryState.Error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      // Tampilkan error di tengah jika list kosong
                      child: Text(
                        'Failed to load history: ${viewModel.errorMessage}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                // 3. Tampilkan Pesan Kosong
                if (viewModel.sessions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No workout history yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // 4. Tampilkan Daftar
                return ListView.builder(
                  // Pastikan ListView selalu bisa di-scroll agar RefreshIndicator berfungsi
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: viewModel.sessions.length,
                  itemBuilder: (context, index) {
                    final WorkoutSessionModel session = viewModel.sessions[index];
                    final formattedDate =
                        DateFormat('EEEE, d MMM yyyy', 'en_US').format(session.startTime);
                    final formattedTime =
                        DateFormat('HH:mm', 'en_US').format(session.startTime);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          formattedDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.onPrimary),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start: $formattedTime',
                                  style: const TextStyle(color: AppColors.textSecondary)),
                              Text('Duration: ${session.formattedDuration}',
                                  style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Text(
                                'Exercises: ${session.exercisesSummary}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.textSecondary.withOpacity(0.8)),
                              ),
                              // --- Tampilkan notes/bw di list (opsional) ---
                              if (session.notes != null && session.notes!.isNotEmpty)
                                  Text('Notes: ${session.notes}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                              if (session.bodyWeight != null)
                                  Text('Weight: ${session.bodyWeight} kg', style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                              // ---------------------------------------------
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutSessionDetailScreen(session: session),
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
        },
      ),
    );
  }
}

