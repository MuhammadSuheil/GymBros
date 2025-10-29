import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodel/streak_viewmodel.dart';
import '../../../core/constants/app_colors.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Streak'),
        actions: [
           IconButton(
             icon: const Icon(Icons.refresh),
             tooltip: 'Reload Streak',
             onPressed: () => context.read<StreakViewModel>().fetchAllStreakData(),
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

          // --- UI BARU ---
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Mulai dari atas
              children: [
                const SizedBox(height: 20),
                // 1. Tampilan Angka Streak & Ikon Api
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40,),
                    // Ganti dengan gambar api Anda nanti
                    Image.asset('assets/images/fire.png', height: 150,),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 25,),
                        Text(
                          '${viewModel.currentStreak}',
                          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, height: 1.1, color: AppColors.onPrimary),
                        ),
                        Text(
                          viewModel.currentStreak == 1 ? 'Day Streak!' : 'Days Streak!',
                          style: const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 20),
                
                // 2. Teks Info Tambahan
                Text(
                  viewModel.currentStreak > 0
                    ? 'Your streak is active! Keep it up!'
                    : 'Complete a workout to start your streak.',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // 3. Kalender Mingguan (7 Lingkaran)
                _buildWeeklyCalendar(
                   context,
                   viewModel.workoutDates, 
                   viewModel.currentStreak, 
                   viewModel.lastWorkoutDate
                ),
                
                const SizedBox(height: 30),
                // 4. Info Tanggal Terakhir
                if (viewModel.lastWorkoutDate != null)
                   Text(
                     'Last workout: ${DateFormat('EEEE, d MMM yyyy', 'en_US').format(viewModel.lastWorkoutDate!)}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                   )
                 else
                    const Text(
                     'No workout history found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
              ],
            ),
          );
          // --- AKHIR UI BARU ---
        },
      ),
    );
  }

  // Helper untuk membangun 7 lingkaran kalender
  Widget _buildWeeklyCalendar(BuildContext context, List<DateTime> workoutDates, int currentStreak, DateTime? lastWorkoutDate) {
    final List<String> weekDayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // Minggu - Sabtu
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Temukan hari Minggu di awal minggu ini
    // DateTime.sunday = 7. (today.weekday % 7) akan 0 untuk Minggu, 1 untuk Senin, ... 6 untuk Sabtu
    final int daysSinceSunday = today.weekday % 7; 
    final DateTime startOfWeek = today.subtract(Duration(days: daysSinceSunday));

    // Normalisasi tanggal workout sekali saja
    final Set<DateTime> normalizedWorkoutDates = workoutDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    final DateTime? normalizedLastWorkoutDate = lastWorkoutDate != null
        ? DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day)
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final DateTime dayToDisplay = startOfWeek.add(Duration(days: index));
        final String label = weekDayLabels[index];

        // Tentukan status lingkaran
        final bool isToday = dayToDisplay == today;
        final bool didWorkout = normalizedWorkoutDates.contains(dayToDisplay);
        final bool isFuture = dayToDisplay.isAfter(today);
        bool isToleranceDay = false;

        if (!didWorkout && !isFuture && !isToday && normalizedLastWorkoutDate != null && currentStreak > 0) {
           final int daysSinceLast = dayToDisplay.difference(normalizedLastWorkoutDate).inDays;
           if (daysSinceLast > 0 && daysSinceLast <= 4) {
              isToleranceDay = true;
           }
        }
        Color circleColor;
        Widget circleChild = Container();
        Border border = Border.all(color: Colors.transparent, width: 2.0); // Default border transparan

        if (isToday) {
          if (didWorkout) {
             // Sudah workout hari ini
             circleChild = const Icon(Icons.local_fire_department, color: Colors.white, size: 20);
             circleColor = const Color.fromARGB(255, 255, 102, 64); // Api
             border = Border.all(color: AppColors.primary, width: 2.0); // Border biru (aktif)
          } else {
             // FITUR BARU: Belum workout hari ini
             circleChild = Container();
             circleColor = AppColors.surface; // Warna surface
             border = Border.all(color: AppColors.error, width: 2.0); // Outline merah
          }
        } 
        // Logika untuk hari-hari lain
        else if (isFuture) {
           circleColor = AppColors.divider.withOpacity(0.2); // Masa depan
        } else if (didWorkout) {
           circleChild = const Icon(Icons.local_fire_department, color: Colors.white, size: 20);
           circleColor = const Color.fromARGB(255, 255, 102, 64); // Api
        } else if (isToleranceDay) {
           circleChild = Container();
           circleColor = const Color.fromARGB(255, 198, 35, 2); // Toleransi (merah)
        } else {
           circleColor = AppColors.surface; // Kosong (putih/abu)
        }
        // --- AKHIR PERBAIKAN LOGIKA ---



        // Buat UI Lingkaran
        return Column(
          children: [
             Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
             const SizedBox(height: 8),
             Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: circleColor,
                 border: Border.all(
                   color: dayToDisplay == today ? AppColors.primary : Colors.transparent, // Border untuk hari ini
                   width: 2.0,
                 )
               ),
               child: Center(child: circleChild),
             ),
          ],
        );
      }),
    );
  }
}

