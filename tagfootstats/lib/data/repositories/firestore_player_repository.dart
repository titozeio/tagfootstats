import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/player_repository.dart';
import '../models/player_model.dart';

class FirestorePlayerRepository implements PlayerRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'players';

  FirestorePlayerRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Player>> getPlayersByTeam(String teamId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('teamId', isEqualTo: teamId)
        .get();
    return snapshot.docs
        .map((doc) => PlayerModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<Player?> getPlayerById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return PlayerModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> savePlayer(Player player) async {
    final model = PlayerModel.fromEntity(player);
    await _firestore
        .collection(_collectionPath)
        .doc(player.id.isEmpty ? null : player.id)
        .set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deletePlayer(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
