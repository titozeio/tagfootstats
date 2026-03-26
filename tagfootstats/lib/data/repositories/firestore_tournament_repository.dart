import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../models/tournament_model.dart';

class FirestoreTournamentRepository implements TournamentRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'tournaments';

  FirestoreTournamentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Tournament>> getTournaments() async {
    final snapshot = await _firestore.collection(_collectionPath).get();
    return snapshot.docs
        .map((doc) => TournamentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<Tournament?> getTournamentById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return TournamentModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> saveTournament(Tournament tournament) async {
    final model = TournamentModel.fromEntity(tournament);
    await _firestore
        .collection(_collectionPath)
        .doc(tournament.id.isEmpty ? null : tournament.id)
        .set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTournament(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
