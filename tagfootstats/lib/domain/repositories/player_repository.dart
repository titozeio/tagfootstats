import '../entities/player.dart';

abstract class PlayerRepository {
  Future<List<Player>> getPlayersByTeam(String teamId);
  Future<Player?> getPlayerById(String id);
  Future<void> savePlayer(Player player);
  Future<void> deletePlayer(String id);
}
