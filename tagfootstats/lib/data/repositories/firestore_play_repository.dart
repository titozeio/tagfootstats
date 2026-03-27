import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/play.dart';
import '../../domain/repositories/play_repository.dart';
import '../models/play_model.dart';

class FirestorePlayRepository implements PlayRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'plays';

  FirestorePlayRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Play>> getPlaysByMatch(String matchId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('matchId', isEqualTo: matchId)
        .get();
    return snapshot.docs
        .map((doc) => PlayModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<void> savePlay(Play play) async {
    final model = PlayModel.fromEntity(play);
    await _firestore
        .collection(_collectionPath)
        .doc(play.id.isEmpty ? null : play.id)
        .set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<List<Play>> getPlaysByMatches(List<String> matchIds) async {
    if (matchIds.isEmpty) return [];

    // Firestore whereIn limit is 30. If more, we should chunk.
    final List<Play> allPlays = [];
    for (var i = 0; i < matchIds.length; i += 30) {
      final chunk = matchIds.sublist(
        i,
        i + 30 > matchIds.length ? matchIds.length : i + 30,
      );
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('matchId', whereIn: chunk)
          .get();
      allPlays.addAll(
        snapshot.docs.map(
          (doc) => PlayModel.fromJson({...doc.data(), 'id': doc.id}),
        ),
      );
    }
    return allPlays;
  }

  @override
  Future<void> deletePlay(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }

  @override
  Stream<List<Play>> watchPlaysByMatch(String matchId) {
    return _firestore
        .collection(_collectionPath)
        .where('matchId', isEqualTo: matchId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PlayModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}
