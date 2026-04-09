import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/stats_aggregator.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';

class AdvancedStatsPage extends StatelessWidget {
  const AdvancedStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ESTADÍSTICAS AVANZADAS'),
          bottom: const TabBar(
            labelColor: AppColors.nflGold,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.nflGold,
            tabs: [
              Tab(text: 'EQUIPOS'),
              Tab(text: 'JUGADORES'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is! AppReady) {
              return const Center(child: CircularProgressIndicator());
            }
            return _AdvancedStatsLoader(
              ownTeamId: state.ownTeam.id,
              ownTeamName: state.ownTeam.name,
            );
          },
        ),
      ),
    );
  }
}

class _AdvancedStatsLoader extends StatelessWidget {
  final String ownTeamId;
  final String ownTeamName;

  const _AdvancedStatsLoader({
    required this.ownTeamId,
    required this.ownTeamName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AggregatedStats>(
      future: _loadStats(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final aggregated = snapshot.data!;
        return TabBarView(
          children: [
            _TeamsTab(teamStats: aggregated.teamStats),
            _PlayersTab(playerStats: aggregated.playerStats),
          ],
        );
      },
    );
  }

  Future<AggregatedStats> _loadStats(BuildContext context) async {
    final matchRepo = context.read<MatchRepository>();
    final playRepo = context.read<PlayRepository>();
    final playerRepo = context.read<PlayerRepository>();
    final teamRepo = context.read<TeamRepository>();

    final matches = (await matchRepo.getMatches())
        .where((match) => hasValidOpponentReference(match.opponentId))
        .toList();
    final plays = await playRepo.getPlaysByMatches(matches.map((m) => m.id).toList());
    final teams = await teamRepo.getTeams();
    final teamNamesById = {for (final team in teams) team.id: team.name};

    final relevantTeamIds = <String>{ownTeamId};
    for (final match in matches) {
      relevantTeamIds.add(
        canonicalizeTeamReference(match.opponentId, teamNamesById),
      );
    }

    final playersByTeam = await Future.wait(
      relevantTeamIds.map(playerRepo.getPlayersByTeam),
    );
    final players = playersByTeam.expand((teamPlayers) => teamPlayers).toList();

    return aggregateStats(
      matches: matches,
      plays: plays,
      ownTeamId: ownTeamId,
      ownTeamName: ownTeamName,
      teamNamesById: teamNamesById,
      players: players,
    );
  }
}

class _TeamsTab extends StatelessWidget {
  final List<TeamStatsAggregate> teamStats;

  const _TeamsTab({required this.teamStats});

  @override
  Widget build(BuildContext context) {
    if (teamStats.isEmpty) {
      return const Center(child: Text('No hay estadísticas de equipos'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: teamStats.length,
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final stats = teamStats[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats.teamName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'PJ ${stats.matches} | PF ${stats.pointsFor} | PC ${stats.pointsAgainst} | YDS ${stats.totalYards}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(label: 'PASE', value: stats.passes),
                  _StatChip(label: 'CARRERA', value: stats.runs),
                  _StatChip(label: 'SACK', value: stats.sacks),
                  _StatChip(label: 'SACK REC', value: stats.sacksReceived),
                  _StatChip(label: 'FUMBLE', value: stats.fumbles),
                  _StatChip(label: 'FALTA', value: stats.fouls),
                  _StatChip(label: 'TD', value: stats.touchdowns),
                  _StatChip(label: 'NO PAT', value: stats.noPat),
                  _StatChip(label: '1PT', value: stats.pat1),
                  _StatChip(label: '2PT', value: stats.pat2),
                  _StatChip(label: 'FLAG', value: stats.flagPulls),
                  _StatChip(label: 'INT', value: stats.interceptions),
                  _StatChip(label: 'BATTED', value: stats.batted),
                  _StatChip(label: 'SAFETY', value: stats.safeties),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayersTab extends StatelessWidget {
  final List<PlayerStatsAggregate> playerStats;

  const _PlayersTab({required this.playerStats});

  @override
  Widget build(BuildContext context) {
    if (playerStats.isEmpty) {
      return const Center(child: Text('No hay estadísticas de jugadores'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 16,
            headingRowColor: WidgetStateProperty.all(Colors.white10),
            columns: const [
              DataColumn(label: Text('EQUIPO')),
              DataColumn(label: Text('JUGADOR')),
              DataColumn(numeric: true, label: Text('PTS')),
              DataColumn(numeric: true, label: Text('YDS')),
              DataColumn(numeric: true, label: Text('PASE')),
              DataColumn(numeric: true, label: Text('CARR')),
              DataColumn(numeric: true, label: Text('SACK')),
              DataColumn(numeric: true, label: Text('FUM')),
              DataColumn(numeric: true, label: Text('FAL')),
              DataColumn(numeric: true, label: Text('TD')),
              DataColumn(numeric: true, label: Text('1PT')),
              DataColumn(numeric: true, label: Text('2PT')),
              DataColumn(numeric: true, label: Text('FLAG')),
              DataColumn(numeric: true, label: Text('INT')),
              DataColumn(numeric: true, label: Text('BAT')),
              DataColumn(numeric: true, label: Text('SAF')),
            ],
            rows: playerStats.map((stats) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      stats.teamName.toUpperCase(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white12,
                          child: ClipOval(
                            child: (stats.photoUrl != null &&
                                    stats.photoUrl!.trim().isNotEmpty)
                                ? Image.network(
                                    stats.photoUrl!.trim(),
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.person, size: 14),
                                  )
                                : const Icon(Icons.person, size: 14),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stats.playerName.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '#${stats.dorsal}',
                              style: const TextStyle(
                                color: AppColors.nflGold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text('${stats.points}')),
                  DataCell(Text('${stats.yards}')),
                  DataCell(Text('${stats.passes}')),
                  DataCell(Text('${stats.runs}')),
                  DataCell(Text('${stats.sacks}')),
                  DataCell(Text('${stats.fumbles}')),
                  DataCell(Text('${stats.fouls}')),
                  DataCell(Text('${stats.touchdowns}')),
                  DataCell(Text('${stats.pat1}')),
                  DataCell(Text('${stats.pat2}')),
                  DataCell(Text('${stats.flagPulls}')),
                  DataCell(Text('${stats.interceptions}')),
                  DataCell(Text('${stats.batted}')),
                  DataCell(Text('${stats.safeties}')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.nflGold,
            ),
          ),
        ],
      ),
    );
  }
}
