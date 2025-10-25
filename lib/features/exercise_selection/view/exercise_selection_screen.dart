import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/exercise_model.dart';
import '../viewmodel/exercise_viewmodel.dart';
import '../../../data/repositories/exercise_repository.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late ExerciseViewModel _viewModel;

  bool _showClearButton = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<ExerciseViewModel>(context, listen: false);

      if (_viewModel.exercises.isEmpty && !_viewModel.isLoading) {
         _viewModel.fetchInitialExercises();
      }
      _scrollController.addListener(_scrollListener);
      _searchController.addListener(_searchListener); 
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_viewModel.isLoading &&
        !_viewModel.isFetchingMore) {
      print("[ExerciseSelectionScreen] Reached bottom, fetching more...");
      _viewModel.fetchMoreExercises(); 
    }
  }

  void _searchListener() {
     _viewModel.onSearchChanged(_searchController.text);
     
     if (mounted) { 
       setState(() {
         _showClearButton = _searchController.text.isNotEmpty;
       });
     }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _searchController.removeListener(_searchListener); 
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = Theme.of(context).primaryColor;
    final brightness = ThemeData.estimateBrightnessForColor(appBarColor);
    final iconColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    final hintColor = iconColor.withOpacity(0.7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor, 
        iconTheme: IconThemeData(color: iconColor), 
        title: TextField(
           controller: _searchController,
           decoration: InputDecoration(
             hintText: 'Search exercises...',
             border: InputBorder.none,
             hintStyle: TextStyle(color: hintColor),
             suffixIcon: _showClearButton 
                ? IconButton(
                    icon: Icon(Icons.clear, color: iconColor),
                    onPressed: () {
                       _searchController.clear();
                    },
                  )
                : null,
           ),
           style: TextStyle(color: iconColor, fontSize: 18),
           cursorColor: iconColor,
        ),
      ),
      body: Consumer<ExerciseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.exercises.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.exercises.isEmpty) {
            return Center(
               child: Text(viewModel.searchQuery.isEmpty
                 ? 'No exercises found.'
                 : 'No results for "${viewModel.searchQuery}"')
             );
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: viewModel.exercises.length + (viewModel.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == viewModel.exercises.length) {
                 return viewModel.isFetchingMore
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink(); 
              }
              final exercise = viewModel.exercises[index];
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
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${exercise.target ?? 'N/A'} | ${exercise.equipment ?? 'N/A'}'),
                  onTap: () {
                    Navigator.of(context).pop(exercise);
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

