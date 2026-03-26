import '../entities/player.dart';
import '../repositories/player_repository.dart';

class ManagePlayers {
  final PlayerRepository repository;

  ManagePlayers(this.repository);

  Future<List<Player>> getPlayersByTeam(String teamId) =>
      repository.getPlayersByTeam(teamId);
  Future<void> savePlayer(Player player) => repository.savePlayer(player);
  Future<void> deletePlayer(String id) => repository.deletePlayer(id);
}
