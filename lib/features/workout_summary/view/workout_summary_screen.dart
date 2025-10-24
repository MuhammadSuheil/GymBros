import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu
import 'package:provider/provider.dart';
import '../../tracking/viewmodel/workout_viewmodel.dart'; // Import viewmodel

class WorkoutSummaryScreen extends StatefulWidget {
  // Data yang diterima dari WorkoutTrackingScreen
  final List<Map<String, dynamic>> setsData;
  final Duration duration;
  final DateTime sessionStartTime;

  const WorkoutSummaryScreen({
    super.key,
    required this.setsData,
    required this.duration,
    required this.sessionStartTime,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final _notesController = TextEditingController();
  final _bodyWeightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _bodyWeightController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan sesi final
  void _saveFinalSession(BuildContext context) async {
     // Validasi input berat badan (opsional)
     if (!_formKey.currentState!.validate()) {
       return;
     }

    final viewModel = Provider.of<WorkoutViewModel>(context, listen: false);
    viewModel.resetErrorState(); // Reset error state

    // Ambil data tambahan
    final String notes = _notesController.text.trim();
    final double? bodyWeight = double.tryParse(
        _bodyWeightController.text.trim().replaceAll(',', '.') // Handle koma desimal
    );

    print("[SummaryScreen] Saving session with notes: $notes, bodyWeight: $bodyWeight");

    // Panggil fungsi saveWorkoutSession di ViewModel (perlu diupdate nanti)
    // Kita tambahkan parameter baru: notes dan bodyWeight
    bool success = await viewModel.saveWorkoutSession(
      setsData: widget.setsData,
      duration: widget.duration,
      sessionStartTime: widget.sessionStartTime,
      // --- Parameter Baru ---
      notes: notes,
      bodyWeight: bodyWeight,
      // --------------------
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout session has been saved!'), duration: Duration(seconds: 2)),
      );
      // Kembali 2x: Tutup SummaryScreen DAN WorkoutTrackingScreen
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saving Failed: ${viewModel.errorMessage}')),
      );
    }
  }

  // Helper untuk format durasi
   String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Helper untuk ringkasan exercises
   String _getExercisesSummary() {
      if (widget.setsData.isEmpty) return 'There is no exercise';
      final exerciseNames = widget.setsData
                                 .map((set) => set['exerciseName'] as String? ?? 'N/A')
                                 .toSet()
                                 .take(5) // Ambil lebih banyak
                                 .join(', ');
      return exerciseNames;
   }

  @override
  Widget build(BuildContext context) {
     final viewModel = context.watch<WorkoutViewModel>(); // Untuk state loading

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Bagian Rangkuman (Read-only) ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Sesi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Date:', DateFormat('EEEE, d MMM yyyy', 'id_ID').format(widget.sessionStartTime)),
                      _buildSummaryRow('Start time:', DateFormat('HH:mm', 'id_ID').format(widget.sessionStartTime)),
                      _buildSummaryRow('Duration:', _formatDuration(widget.duration)),
                      _buildSummaryRow('Total set:', widget.setsData.length.toString()),
                       _buildSummaryRow('Workout:', _getExercisesSummary()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Bagian Input Tambahan ---
              Text(
                'Info Tambahan (Opsional)',
                 style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Input Catatan
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Workout Notes',
                  hintText: 'how are you feeling? any new PRs?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Agar label di atas saat multi-line
                ),
                maxLines: 3, // Beberapa baris
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Input Berat Badan
              TextFormField(
                controller: _bodyWeightController,
                decoration: const InputDecoration(
                  labelText: 'Body Weight',
                  hintText: 'ex: 70',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')),
                ],
                 validator: (value) {
                    if (value == null || value.isEmpty) return null; // Boleh kosong
                    final weight = double.tryParse(value.replaceAll(',', '.'));
                    if (weight == null) {
                       return 'Enter a valid number!';
                    }
                    if (weight <= 0) {
                       return 'Invalid Bodyweight';
                    }
                    return null;
                 },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan Final
              ElevatedButton(
                onPressed: viewModel.state == ViewState.Loading ? null : () => _saveFinalSession(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: viewModel.state == ViewState.Loading
                  ? const CircularProgressIndicator(color: Colors.white,)
                  : const Text('Save Workout Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk baris rangkuman
  Widget _buildSummaryRow(String label, String value) {
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
