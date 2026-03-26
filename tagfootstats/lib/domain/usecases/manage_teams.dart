import '../entities/team.dart';
import '../repositories/team_repository.dart';

class ManageTeams {
  final TeamRepository repository;

  ManageTeams(this.repository);

  Future<List<Team>> getAllTeams() => repository.getTeams();
  Future<void> saveTeam(Team team) => repository.saveTeam(team);
  Future<void> deleteTeam(String id) => repository.deleteTeam(id);
  Future<Team?> getOwnTeam() => repository.getOwnTeam();
}
