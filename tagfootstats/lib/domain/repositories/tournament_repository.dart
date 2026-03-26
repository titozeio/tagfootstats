import '../entities/tournament.dart';

abstract class TournamentRepository {
  Future<List<Tournament>> getTournaments();
  Future<Tournament?> getTournamentById(String id);
  Future<void> saveTournament(Tournament tournament);
  Future<void> deleteTournament(String id);
}
