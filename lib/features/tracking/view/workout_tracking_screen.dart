import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../../data/models/exercise_model.dart';
import '../../../data/models/set_entry_model.dart';
import '../../../data/models/workout_group_model.dart';
import '../viewmodel/workout_viewmodel.dart';
import '../../exercise_selection/view/exercise_selection_screen.dart';
import '../../exercise_detail/view/exercise_detail_screen.dart';
import '../../workout_summary/view/workout_summary_screen.dart';

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
  bool _isInitialized = false; 

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) { 
          _startTimer();
          setState(() {
             _isInitialized = true; 
          });
       }
    });
    
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return; 
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
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
  void _navigateAndAddExercise() async {
    final selectedExercise = await Navigator.push<ExerciseModel>(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseSelectionScreen()),
    );

    if (selectedExercise != null && mounted) {
      bool groupExists = _workoutGroups.any((group) => group.exercise.id == selectedExercise.id);
      if (groupExists) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('${selectedExercise.name} is already added'))
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
  void _addSetToGroup(WorkoutGroup group) {
     if (mounted) {
       setState(() {
         group.sets.add(SetEntry());
       });
     }
  }
  void _deleteSetFromGroup(WorkoutGroup group, SetEntry setToDelete) {
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
  void _deleteWorkoutGroup(WorkoutGroup groupToDelete) {
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
  void _replaceExercise(WorkoutGroup groupToReplace) async {
     final newSelectedExercise = await Navigator.push<ExerciseModel>(
       context,
       MaterialPageRoute(builder: (context) => const ExerciseSelectionScreen()),
     );

     if (newSelectedExercise != null && mounted) {
       bool newExerciseExists = _workoutGroups.any((group) => group.exercise.id == newSelectedExercise.id && group != groupToReplace);
        if (newExerciseExists) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('${newSelectedExercise.name} is already added'))
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
  void _finishWorkout() { // Ganti nama fungsi agar lebih jelas
     // Validasi checklist dan data input
     bool allSetsCompleted = true;
     bool allValid = true;
     List<Map<String, dynamic>> sessionData = [];

      for (var group in _workoutGroups) {
       for (int i = 0; i < group.sets.length; i++) {
          final setEntry = group.sets[i];
          if (!setEntry.isCompleted) {
             allSetsCompleted = false;
             break;
          }
          // Validasi input
          final reps = int.tryParse(setEntry.repsController.text);
          final weightText = setEntry.weightController.text.trim().replaceAll(',', '.');
          final weight = double.tryParse(weightText);

          if (setEntry.repsController.text.trim().isEmpty || weightText.isEmpty || reps == null || weight == null) {
              allValid = false;
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Invalid Reps/Weight data on: ${group.exercise.name} (Set ${i + 1})')),
               );
               break;
          }
           sessionData.add({ /* ... (data set sama) ... */
             'exerciseId': group.exercise.id,
             'exerciseName': group.exercise.name,
             'setNumber': i + 1,
             'reps': reps,
             'weight': weight,
             'isCompleted': setEntry.isCompleted,
           });
       }
       if (!allSetsCompleted || !allValid) break;
     }

     // Cek hasil validasi
     if (!allSetsCompleted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please press all the check button before submitting')),
       );
       return;
     }
      if (!allValid || sessionData.isEmpty) {
        if (sessionData.isEmpty && allValid && allSetsCompleted) { // Kasus jika belum ada set sama sekali
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add some exercise')));
        }
       return; // Error sudah ditampilkan sebelumnya jika !allValid
     }


    // Jika semua valid, navigasi ke Summary Screen
    print("[TrackingScreen] Finishing workout, navigating to Summary...");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(
          setsData: sessionData,
          duration: _duration,
          sessionStartTime: _sessionStartTime,
        ),
      ),
    );
  }

  @override
  void dispose() {
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

     
     if (!_isInitialized) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
     }
     

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
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
                          'Press the "Start Workout" button down below to start',
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
                label: const Text('Add exercise'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)
                ),
              ),
            ),

            if (_workoutGroups.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                child: ElevatedButton(
                  onPressed: viewModel.state == ViewState.Loading ? null : _finishWorkout,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: viewModel.state == ViewState.Loading
                    ? const CircularProgressIndicator(color: Colors.white,)
                    : const Text('Finish & Save Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class WorkoutGroupTile extends StatelessWidget {
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
                          title: Text('Replace Exercise'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_all',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                          title: Text('Delete all set'),
                          dense: true,
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 20),
                    tooltip: 'Exercise option',
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


class SetRow extends StatelessWidget {
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
            flex: 3,
            child: TextFormField(
              controller: setEntry.weightController.text == '0.0' ? (TextEditingController()..text = '') : setEntry.weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)', isDense: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[ FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')), ],
            ),
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

