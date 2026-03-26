import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/match_repository.dart';
import '../models/match_model.dart';

class FirestoreMatchRepository implements MatchRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'matches';

  FirestoreMatchRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Match>> getMatchesByTournament(String tournamentId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('tournamentId', isEqualTo: tournamentId)
        .get();
    return snapshot.docs
        .map((doc) => MatchModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<Match?> getMatchById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return MatchModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> saveMatch(Match match) async {
    final model = MatchModel.fromEntity(match);
    await _firestore
        .collection(_collectionPath)
        .doc(match.id.isEmpty ? null : match.id)
        .set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteMatch(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }

  @override
  Stream<Match?> watchMatch(String id) {
    return _firestore.collection(_collectionPath).doc(id).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return MatchModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }
}
