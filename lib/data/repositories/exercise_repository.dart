import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final CollectionReference _exercisesCollection =
      FirebaseFirestore.instance.collection('exercises');

  final int _perPage = 50;

  Future<Map<String, dynamic>> getExercisesPaginated(
      {DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _exercisesCollection.orderBy('name').limit(_perPage);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();

      final exercises =
          snapshot.docs.map((doc) => ExerciseModel.fromSnapshot(doc)).toList();

      final DocumentSnapshot? newLastDocument =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return {
        'exercises': exercises,
        'lastDocument': newLastDocument,
      };
    } catch (e) {
      print('Error fetching paginated exercises: $e');
      throw Exception('Gagal memuat data latihan.');
    }
  }
}

