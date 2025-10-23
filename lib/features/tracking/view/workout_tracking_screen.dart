import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk InputFormatter
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../../../data/models/exercise_model.dart';
import '../../../data/models/set_entry_model.dart';
import '../../../data/models/workout_group_model.dart';
import '../../exercise_selection/view/exercise_selection_screen.dart';
import '../../exercise_detail/view/exercise_detail_screen.dart';
import '../viewmodel/workout_viewmodel.dart';

class WorkoutTrackingScreen extends StatefulWidget {
  const WorkoutTrackingScreen({super.key});

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  final List<WorkoutGroup> _workoutGroups = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _timer;
  Duration _duration = Duration.zero;
  late DateTime _sessionStartTime;
  bool _isInitialized = false; // Flag untuk menandai inisialisasi

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    // --- PERBAIKAN CRASH: Tunda start timer sedikit ---
    // Kadang initState berjalan terlalu cepat sebelum semua siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) { // Pastikan widget masih ada
          _startTimer();
          setState(() {
             _isInitialized = true; // Tandai inisialisasi selesai
          });
       }
    });
    // --- AKHIR PERBAIKAN CRASH ---
  }

  void _startTimer() { /* ... (sama) ... */
    if (_timer != null && _timer!.isActive) return; // Hindari duplikasi timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds + 1);
        });
      } else {
         timer.cancel();
      }
    });
  }
  String _formatDuration(Duration duration) { /* ... (sama) ... */
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
  void _navigateAndAddExercise() async { /* ... (sama) ... */
    final selectedExercise = await Navigator.push<ExerciseModel>(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseSelectionScreen()),
    );

    if (selectedExercise != null && mounted) {
      bool groupExists = _workoutGroups.any((group) => group.exercise.id == selectedExercise.id);
      if (groupExists) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('${selectedExercise.name} sudah ada. Tambahkan set saja.'))
         );
         int lastIndex = _workoutGroups.lastIndexWhere((group) => group.exercise.id == selectedExercise.id);
         WorkoutGroup targetGroup = _workoutGroups.firstWhere((group) => group.exercise.id == selectedExercise.id);
         _addSetToGroup(targetGroup);

      } else {
        setState(() {
          _workoutGroups.add(WorkoutGroup(exercise: selectedExercise));
        });
      }
    }
  }
  void _addSetToGroup(WorkoutGroup group) { /* ... (sama) ... */
     if (mounted) {
       setState(() {
         group.sets.add(SetEntry());
       });
     }
  }
  void _deleteSetFromGroup(WorkoutGroup group, SetEntry setToDelete) { /* ... (sama) ... */
     if (mounted) {
       setState(() {
         setToDelete.repsController.dispose();
         setToDelete.weightController.dispose();
         group.sets.remove(setToDelete);
         if (group.sets.isEmpty) {
            _workoutGroups.remove(group);
         }
       });
     }
  }
  void _deleteWorkoutGroup(WorkoutGroup groupToDelete) { /* ... (sama) ... */
     if (mounted) {
       setState(() {
         for (var set in groupToDelete.sets) {
           set.repsController.dispose();
           set.weightController.dispose();
         }
         _workoutGroups.remove(groupToDelete);
       });
     }
  }
  void _replaceExercise(WorkoutGroup groupToReplace) async { /* ... (sama) ... */
     final newSelectedExercise = await Navigator.push<ExerciseModel>(
       context,
       MaterialPageRoute(builder: (context) => const ExerciseSelectionScreen()),
     );

     if (newSelectedExercise != null && mounted) {
       bool newExerciseExists = _workoutGroups.any((group) => group.exercise.id == newSelectedExercise.id && group != groupToReplace);
        if (newExerciseExists) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('${newSelectedExercise.name} sudah ada dalam daftar.'))
           );
           return;
        }

       setState(() {
          List<SetEntry> oldSets = List.from(groupToReplace.sets);
          final newGroup = WorkoutGroup(exercise: newSelectedExercise);
          newGroup.sets.clear();
          newGroup.sets.addAll(oldSets);

          int oldIndex = _workoutGroups.indexOf(groupToReplace);
          _workoutGroups.removeAt(oldIndex);
          _workoutGroups.insert(oldIndex, newGroup);
       });
     }
  }
  void _saveWorkoutSession() async { /* ... (sama) ... */
     final viewModel = Provider.of<WorkoutViewModel>(context, listen: false);
     viewModel.resetErrorState();

     bool allSetsCompleted = true;
     for (var group in _workoutGroups) {
       for (var setEntry in group.sets) {
         if (!setEntry.isCompleted) {
           allSetsCompleted = false;
           break;
         }
       }
       if (!allSetsCompleted) break;
     }

     if (!allSetsCompleted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Harap checklist semua set yang sudah diselesaikan sebelum menyimpan.')),
       );
       return;
     }

     List<Map<String, dynamic>> sessionData = [];
     bool allValid = true;

     for (var group in _workoutGroups) {
       for (int i = 0; i < group.sets.length; i++) {
         final setEntry = group.sets[i];
         final reps = int.tryParse(setEntry.repsController.text);
         final weightText = setEntry.weightController.text.trim().replaceAll(',', '.');
         final weight = double.tryParse(weightText);

         if (setEntry.repsController.text.trim().isEmpty || weightText.isEmpty || reps == null || weight == null) {
            allValid = false;
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Data Reps/Beban tidak valid pada: ${group.exercise.name} (Set ${i + 1})')),
             );
             break;
         }
         sessionData.add({
           'exerciseId': group.exercise.id,
           'exerciseName': group.exercise.name,
           'setNumber': i + 1,
           'reps': reps,
           'weight': weight,
           'isCompleted': setEntry.isCompleted,
         });
       }
        if (!allValid) break;
     }

     if (allValid && sessionData.isNotEmpty) {
       print("Mengirim data ke ViewModel: $sessionData");
       bool success = await viewModel.saveWorkoutSession(
          setsData: sessionData,
          duration: _duration,
          sessionStartTime: _sessionStartTime,
       );

       if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Sesi latihan berhasil disimpan!'), duration: Duration(seconds: 2),),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
             _duration = Duration.zero;
             _workoutGroups.forEach((group) {
                group.sets.forEach((set) {
                   set.repsController.dispose();
                   set.weightController.dispose();
                });
             });
             _workoutGroups.clear();
             Navigator.of(context).pop();
          }
       } else if (!success && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal menyimpan: ${viewModel.errorMessage}')),
         );
       }

     } else if (sessionData.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada latihan untuk disimpan.')),
      );
     }
  }

  @override
  void dispose() { /* ... (sama) ... */
    _timer?.cancel();
    for (var group in _workoutGroups) {
      for (var set in group.sets) {
        set.repsController.dispose();
        set.weightController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkoutViewModel>();

     // --- PERBAIKAN CRASH: Tampilkan loading jika belum inisialisasi ---
     if (!_isInitialized) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
     }
     // --- AKHIR PERBAIKAN CRASH ---

    return Scaffold( /* ... (sisanya sama) ... */
      appBar: AppBar(
        title: const Text('Mulai Latihan'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatDuration(_duration),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: _workoutGroups.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Tekan tombol "Tambah Latihan" di bawah untuk memulai.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                         ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _workoutGroups.length,
                      itemBuilder: (context, index) {
                        final group = _workoutGroups[index];
                        return WorkoutGroupTile(
                          key: ValueKey(group.exercise.id),
                          group: group,
                          onAddSet: () => _addSetToGroup(group),
                          onDeleteSet: (setToDelete) => _deleteSetFromGroup(group, setToDelete),
                          onReplaceExercise: () => _replaceExercise(group),
                          onDeleteWorkout: () => _deleteWorkoutGroup(group),
                          onToggleSetComplete: (setEntry, isCompleted) {
                             if (mounted) {
                               setState(() {
                                 setEntry.isCompleted = isCompleted;
                               });
                             }
                          },
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: OutlinedButton.icon(
                onPressed: _navigateAndAddExercise,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Latihan'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)
                ),
              ),
            ),

            if (_workoutGroups.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                child: ElevatedButton(
                  onPressed: viewModel.state == ViewState.Loading ? null : _saveWorkoutSession,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: viewModel.state == ViewState.Loading
                    ? const CircularProgressIndicator(color: Colors.white,)
                    : const Text('Selesai & Simpan Sesi'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget WorkoutGroupTile (sama)
class WorkoutGroupTile extends StatelessWidget { /* ... (sama) ... */
  final WorkoutGroup group;
  final VoidCallback onAddSet;
  final ValueChanged<SetEntry> onDeleteSet;
  final VoidCallback onReplaceExercise;
  final VoidCallback onDeleteWorkout;
  final Function(SetEntry, bool) onToggleSetComplete;

  const WorkoutGroupTile({
    super.key,
    required this.group,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onReplaceExercise,
    required this.onDeleteWorkout,
    required this.onToggleSetComplete,
  });

   @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailScreen(exercise: group.exercise),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          group.exercise.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                 PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'replace':
                          onReplaceExercise();
                          break;
                        case 'delete_all':
                          onDeleteWorkout();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'replace',
                        child: ListTile(
                          leading: Icon(Icons.repeat, size: 20),
                          title: Text('Ganti Latihan'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_all',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                          title: Text('Hapus Semua Set'),
                          dense: true,
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 20),
                    tooltip: 'Opsi Latihan',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  )
              ],
            ),
            const Divider(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.sets.length,
              itemBuilder: (context, index) {
                final setEntry = group.sets[index];
                return SetRow(
                  key: ValueKey(setEntry.id),
                  setEntry: setEntry,
                  setNumber: index + 1,
                  onToggleComplete: (isCompleted) => onToggleSetComplete(setEntry, isCompleted),
                  onDelete: () => onDeleteSet(setEntry),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Set'),
                style: TextButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 8),
                   foregroundColor: Theme.of(context).primaryColor,
                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                   alignment: Alignment.center,
                   textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Widget SetRow (sama)
class SetRow extends StatelessWidget { /* ... (sama) ... */
  final SetEntry setEntry;
  final int setNumber;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onDelete;

  const SetRow({
    super.key,
    required this.setEntry,
    required this.setNumber,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        color: Colors.redAccent.withOpacity(0.1),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20,),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30, height: 30, alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400)
            ),
            child: Text(setNumber.toString(), style: TextStyle(color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: setEntry.repsController,
              decoration: const InputDecoration(labelText: 'Reps', isDense: true),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[ FilteringTextInputFormatter.digitsOnly ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: setEntry.weightController.text == '0.0' ? (TextEditingController()..text = '') : setEntry.weightController,
              decoration: const InputDecoration(labelText: 'Beban (kg)', isDense: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[ FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')), ],
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: setEntry.isCompleted,
            onChanged: (value) {
              onToggleComplete(value ?? false);
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

