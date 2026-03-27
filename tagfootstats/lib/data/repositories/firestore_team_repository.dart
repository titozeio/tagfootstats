import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';
import '../models/team_model.dart';

class FirestoreTeamRepository implements TeamRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'teams';

  FirestoreTeamRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Team>> getTeams() async {
    final snapshot = await _firestore.collection(_collectionPath).get();
    return snapshot.docs
        .map((doc) => TeamModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<Team?> getTeamById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return TeamModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> saveTeam(Team team) async {
    final model = TeamModel.fromEntity(team);
    await _firestore
        .collection(_collectionPath)
        .doc(team.id.isEmpty ? null : team.id)
        .set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTeam(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }

  @override
  Future<Team?> getOwnTeam() async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('isOwnTeam', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return TeamModel.fromJson({...doc.data(), 'id': doc.id});
  }
  @override
  Future<void> setAsOwnTeam(String teamId) async {
    final batch = _firestore.batch();
    
    // 1. Unset all own teams
    final currentOwn = await _firestore
        .collection(_collectionPath)
        .where('isOwnTeam', isEqualTo: true)
        .get();
    
    for (var doc in currentOwn.docs) {
      batch.update(doc.reference, {'isOwnTeam': false});
    }
    
    // 2. Set new own team
    batch.update(
      _firestore.collection(_collectionPath).doc(teamId),
      {'isOwnTeam': true},
    );
    
    await batch.commit();
  }
}
