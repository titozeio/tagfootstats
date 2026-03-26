import '../entities/play.dart';

abstract class PlayRepository {
  Future<List<Play>> getPlaysByMatch(String matchId);
  Future<void> savePlay(Play play);
  Future<void> deletePlay(String id);
  Stream<List<Play>> watchPlaysByMatch(String matchId);
}
