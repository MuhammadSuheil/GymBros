import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final CollectionReference _exercisesCollection =
      FirebaseFirestore.instance.collection('exercises');
  final int _perPage = 50;
  int get itemsPerPage => _perPage;

  Future<Map<String, dynamic>> getExercisesPaginated(
      {DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _exercisesCollection.orderBy('name').limit(itemsPerPage);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      QuerySnapshot snapshot = await query.get();
      final exercises = snapshot.docs.map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
      final DocumentSnapshot? newLastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return {'exercises': exercises, 'lastDocument': newLastDocument};
    } catch (e) {
       print('[ExerciseRepository] Error fetching paginated exercises: $e');
       throw Exception('Failed to load exercises.');
    }
  }

  Future<Map<String, dynamic>> searchExercisesPaginated({
    required String query, 
    DocumentSnapshot? lastDocument,
  }) async {
    if (query.isEmpty) {
      return getExercisesPaginated(lastDocument: lastDocument);
    }

    try {
      String queryCapitalized = query.isNotEmpty
          ? query[0].toUpperCase() + (query.length > 1 ? query.substring(1) : '')
          : ''; 

      Query firestoreQuery = _exercisesCollection
          .where('name', isGreaterThanOrEqualTo: queryCapitalized) 
          .where('name', isLessThanOrEqualTo: '$queryCapitalized\uf8ff') 
          .orderBy('name')
          .limit(itemsPerPage);

      if (lastDocument != null) {
        firestoreQuery = firestoreQuery.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await firestoreQuery.get();
      final exercises = snapshot.docs.map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
      final DocumentSnapshot? newLastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      print("[ExerciseRepository] Search Capitalized '$queryCapitalized': Found ${exercises.length} results for ViewModel to filter.");
      return {'exercises': exercises, 'lastDocument': newLastDocument};
    } catch (e) {
      print('[ExerciseRepository] Error searching exercises: $e');
      throw Exception('Failed to search exercises. Check Firestore index.');
    }
  }
  
}

