import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/player.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';

class PlayerListPage extends StatelessWidget {
  final String? teamId;

  const PlayerListPage({super.key, this.teamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JUGADORES'),
        actions: [
          if (teamId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/player/new/$teamId'),
            ),
        ],
      ),
      body: teamId == null
          ? _buildTeamPicker(context)
          : _buildPlayerList(context, teamId!),
    );
  }

  Widget _buildTeamPicker(BuildContext context) {
    return FutureBuilder<List<Team>>(
      future: context.read<TeamRepository>().getTeams(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final teams = snapshot.data!;
        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return ListTile(
              title: Text(team.name.toUpperCase()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/players/${team.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerList(BuildContext context, String teamId) {
    return FutureBuilder<List<Player>>(
      future: context.read<PlayerRepository>().getPlayersByTeam(teamId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No se han encontrado jugadores para este equipo.'),
          );
        }

        final players = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return ListTile(
              leading: SizedBox(
                width: 70,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white12,
                      child: ClipOval(
                        child:
                            (player.photoUrl != null &&
                                player.photoUrl!.trim().isNotEmpty)
                            ? Image.network(
                                player.photoUrl!.trim(),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                      size: 20,
                                      color: Colors.white24,
                                    ),
                              )
                            : const Icon(Icons.person, color: Colors.white30),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          border: Border.all(
                            color: AppColors.nflGold,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${player.dorsal}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                '${player.firstName} ${player.lastName}'.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: player.position == PlayerPosition.offense
                          ? AppColors.primaryBlue.withOpacity(0.3)
                          : player.position == PlayerPosition.defense
                          ? AppColors.accentRed.withOpacity(0.3)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      player.position.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => context.push('/player/${player.id}'),
            );
          },
        );
      },
    );
  }
}
