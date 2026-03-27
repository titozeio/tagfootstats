import '../entities/play.dart';

abstract class PlayRepository {
  Future<List<Play>> getPlaysByMatch(String matchId);
  Future<void> savePlay(Play play);
  Future<void> deletePlay(String id);
  Future<List<Play>> getPlaysByMatches(List<String> matchIds);
  Stream<List<Play>> watchPlaysByMatch(String matchId);
}
