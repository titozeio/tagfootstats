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
        title: const Text('PLAYERS'),
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Center(child: Text('No players found for this team.'));

        final players = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.nflGold,
                child: Text(
                  player.dorsal.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${player.firstName} ${player.lastName}'.toUpperCase(),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => context.push('/player/${player.id}'),
            );
          },
        );
      },
    );
  }
}
