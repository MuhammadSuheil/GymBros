import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../tracking/viewmodel/workout_viewmodel.dart';

class WorkoutSummaryScreen extends StatefulWidget {
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

  void _saveFinalSession(BuildContext context) async {
     if (!_formKey.currentState!.validate()) { return; }

    final viewModel = Provider.of<WorkoutViewModel>(context, listen: false);
    viewModel.resetErrorState();

    final String notes = _notesController.text.trim();
    final double? bodyWeight = double.tryParse(
        _bodyWeightController.text.trim().replaceAll(',', '.')
    );
    print("[SummaryScreen] Values read from controllers:");
    print("  Notes: '$notes'"); 
    print("  BodyWeight (parsed): $bodyWeight");
    print("[SummaryScreen] Saving session with notes: $notes, bodyWeight: $bodyWeight");

    
    bool success = await viewModel.saveWorkoutSession(
      setsData: widget.setsData,
      duration: widget.duration,
      sessionStartTime: widget.sessionStartTime,
      notes: notes.isNotEmpty ? notes : null,
      bodyWeight: bodyWeight,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout session saved successfully!'), duration: Duration(seconds: 2)),
      );
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saving Failed: ${viewModel.errorMessage}')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

   String _getExercisesSummary() {
      if (widget.setsData.isEmpty) return 'No exercises';
      final exerciseNames = widget.setsData.map((set) => set['exerciseName'] as String? ?? 'N/A').toSet().take(5).join(', ');
      return exerciseNames;
   }

  @override
  Widget build(BuildContext context) {
     final viewModel = context.watch<WorkoutViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Date:', DateFormat('EEEE, d MMM yyyy', 'en_US').format(widget.sessionStartTime)),
                      _buildSummaryRow('Start Time:', DateFormat('HH:mm', 'en_US').format(widget.sessionStartTime)),
                      _buildSummaryRow('Duration:', _formatDuration(widget.duration)),
                      _buildSummaryRow('Total Sets:', widget.setsData.length.toString()),
                      _buildSummaryRow('Exercises:', _getExercisesSummary()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Additional Info (Optional)',
                 style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Workout Notes',
                  hintText: 'How did it feel? Any PRs?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bodyWeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Body Weight (kg)',
                  hintText: 'Example: 75.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')),
                ],
                 validator: (value) {
                    if (value == null || value.isEmpty) return null;
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

