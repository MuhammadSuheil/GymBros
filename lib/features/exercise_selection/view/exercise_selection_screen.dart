import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/exercise_viewmodel.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ExerciseViewModel>(context, listen: false);

    _scrollController.addListener(() {
      final viewModel = Provider.of<ExerciseViewModel>(context, listen: false);
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.fetchMoreExercises();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Latihan'),
      ),
      body: Consumer<ExerciseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.exercises.isEmpty && viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.exercises.isEmpty) {
            return const Center(child: Text('Tidak ada data latihan.'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: viewModel.exercises.length + (viewModel.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == viewModel.exercises.length) {
                return viewModel.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }

              final exercise = viewModel.exercises[index];
              
              //debug
              if (index == 0) { 
                print('[DEBUG] Image URL: ${exercise.imageUrl}');
              }
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      exercise.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${exercise.equipment}'),
                  onTap: () {
                    print('Memilih: ${exercise.name}');
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
