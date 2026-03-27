import '../entities/team.dart';

abstract class TeamRepository {
  Future<List<Team>> getTeams();
  Future<Team?> getTeamById(String id);
  Future<void> saveTeam(Team team);
  Future<void> deleteTeam(String id);
  Future<Team?> getOwnTeam();
  Future<void> setAsOwnTeam(String teamId);
}
