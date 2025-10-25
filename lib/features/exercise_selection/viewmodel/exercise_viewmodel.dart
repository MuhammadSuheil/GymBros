import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/exercise_repository.dart';

class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _repository = ExerciseRepository();

  List<ExerciseModel> exercises = [];
  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  Timer? debounce;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void onSearchChanged(String query) {
    final trimmedQuery = query.trim();
    if (_searchQuery != trimmedQuery || (trimmedQuery.isEmpty && exercises.isEmpty && !isLoading)) {
       _searchQuery = trimmedQuery;
       _triggerFetchWithDebounce();
    }
  }

  void _triggerFetchWithDebounce() {
     
     WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading = true;
        exercises.clear();
        _lastDocument = null;
        hasMoreData = true;
        notifyListeners(); 
     });
     if (debounce?.isActive ?? false) debounce!.cancel();
     debounce = Timer(const Duration(milliseconds: 500), () {
       print("[ExerciseViewModel] Debounce finished, fetching initial results for '$_searchQuery'");
       fetchInitialExercises();
     });
  }

  Future<void> fetchInitialExercises() async {
    try {
      Map<String, dynamic> result;
      if (_searchQuery.isNotEmpty) {
        print("[ExerciseViewModel] Executing search query: '$_searchQuery'");
        result = await _repository.searchExercisesPaginated(query: _searchQuery);
      } else {
         print("[ExerciseViewModel] Executing initial list query.");
        result = await _repository.getExercisesPaginated();
      }
      exercises = result['exercises'];
      _lastDocument = result['lastDocument'];
      hasMoreData = exercises.isNotEmpty && (exercises.length == _repository.itemsPerPage);

      if (_searchQuery.isNotEmpty) {
         final queryLower = _searchQuery.toLowerCase();
         exercises = exercises.where((ex) => ex.name.toLowerCase().startsWith(queryLower)).toList();
      }
      print("[ExerciseViewModel] Initial fetch/search complete. Displaying: ${exercises.length}, hasMoreData: $hasMoreData");
    } catch (e) {
      print("[ExerciseViewModel] Error fetching initial exercises: $e");
      exercises.clear();
      hasMoreData = false;
    } finally {
       isLoading = false; 
       notifyListeners();
    }
  }

  Future<void> fetchMoreExercises() async {
    if (isLoading || isFetchingMore || !hasMoreData || _searchQuery.isNotEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
       isFetchingMore = true;
       notifyListeners();
    });
    await Future.delayed(Duration.zero);

    try {
       Map<String, dynamic> result;
       if (_searchQuery.isEmpty) {
           result = await _repository.getExercisesPaginated(lastDocument: _lastDocument);
       } else { return; } 
      final newExercises = result['exercises'] as List<ExerciseModel>;
      _lastDocument = result['lastDocument'];
      bool fetchedEnough = newExercises.length == _repository.itemsPerPage;

      exercises.addAll(newExercises);
      hasMoreData = newExercises.isNotEmpty && fetchedEnough;

      print("[ExerciseViewModel] Fetched more. New total: ${exercises.length}, hasMoreData: $hasMoreData");
    } catch (e) {
      print("[ExerciseViewModel] Error fetching more exercises: $e");
      hasMoreData = false;
    } finally {
       isFetchingMore = false; 
       notifyListeners(); 
    }
  }
  @override
  void dispose() {
    debounce?.cancel();
    print("[ExerciseViewModel] Disposed."); 
    super.dispose(); 
  }
  
}

