import '../entities/match.dart';

abstract class MatchRepository {
  Future<List<Match>> getMatchesByTournament(String tournamentId);
  Future<Match?> getMatchById(String id);
  Future<void> saveMatch(Match match);
  Future<void> deleteMatch(String id);
  Stream<Match?> watchMatch(String id);
}
