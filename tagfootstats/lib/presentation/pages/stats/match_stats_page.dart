import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/stats_aggregator.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/core/utils/feedback_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';

class MatchStatsPage extends StatelessWidget {
  final Match match;
  final List<Play> plays;
  final List<Player> players;
  final List<Player> opponentPlayers;
  final String ownTeamName;
  final String opponentTeamName;

  const MatchStatsPage({
    super.key,
    required this.match,
    required this.plays,
    required this.players,
    required this.opponentPlayers,
    required this.ownTeamName,
    required this.opponentTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final isUserHome = match.locationType == LocationType.local;
    final homeTeamName = isUserHome ? ownTeamName : opponentTeamName;
    final awayTeamName = isUserHome ? opponentTeamName : ownTeamName;
    final ownTeamId = _resolveOwnTeamId();
    final opponentTeamId = _resolveOpponentTeamId();
    final aggregated = aggregateStats(
      matches: [match],
      plays: plays,
      ownTeamId: ownTeamId,
      ownTeamName: ownTeamName,
      teamNamesById: {opponentTeamId: opponentTeamName},
      players: [...players, ...opponentPlayers],
    );
    final teamStatsByRef = {
      for (final stats in aggregated.teamStats) stats.teamRef: stats,
    };
    final playerStatsByRef = <String, List<PlayerStatsAggregate>>{};
    for (final playerStat in aggregated.playerStats) {
      playerStatsByRef
          .putIfAbsent(playerStat.teamRef, () => [])
          .add(playerStat);
    }
    final homeTeamRef = isUserHome ? ownTeamId : opponentTeamId;
    final awayTeamRef = isUserHome ? opponentTeamId : ownTeamId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESTADÍSTICAS DEL PARTIDO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: () => _copyStatsToClipboard(context),
            tooltip: 'Copiar estadísticas',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildScoreboardHeader(homeTeamName, awayTeamName),
            const SizedBox(height: 16),
            _buildTeamSection(
              teamName: homeTeamName,
              stats: teamStatsByRef[homeTeamRef],
              playerStats: playerStatsByRef[homeTeamRef] ?? const [],
              isHomeTeam: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: Colors.white10, thickness: 2),
            ),
            _buildTeamSection(
              teamName: awayTeamName,
              stats: teamStatsByRef[awayTeamRef],
              playerStats: playerStatsByRef[awayTeamRef] ?? const [],
              isHomeTeam: false,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboardHeader(String homeName, String awayName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreboardTeam(
            homeName,
            match.homeScore,
            isOwn: match.locationType == LocationType.local,
          ),
          const Text(
            'VS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white24,
            ),
          ),
          _buildScoreboardTeam(
            awayName,
            match.awayScore,
            isOwn: match.locationType == LocationType.visitante,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardTeam(String name, int score, {required bool isOwn}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOwn ? AppColors.primaryBlue : AppColors.accentRed,
            boxShadow: [
              BoxShadow(
                color: (isOwn ? AppColors.primaryBlue : AppColors.accentRed)
                    .withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isOwn ? Icons.sports_football : Icons.shield,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.nflGold,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection({
    required String teamName,
    required TeamStatsAggregate? stats,
    required List<PlayerStatsAggregate> playerStats,
    required bool isHomeTeam,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                color: isHomeTeam ? AppColors.primaryBlue : AppColors.accentRed,
              ),
              const SizedBox(width: 8),
              Text(
                teamName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        _buildCompactTeamGrid(stats),
        if (playerStats.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'RENDIMIENTO JUGADORES',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPlayerStatsList(playerStats),
        ] else ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Sin datos de jugadores registrados',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactTeamGrid(TeamStatsAggregate? stats) {
    if (stats == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Sin estadísticas registradas para este equipo',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildCompactStatCard('YDS', '${stats.totalYards}'),
          _buildCompactStatCard('PASE', '${stats.passes}'),
          _buildCompactStatCard('CARR', '${stats.runs}'),
          _buildCompactStatCard('SACK', '${stats.sacks}'),
          _buildCompactStatCard('SACK REC', '${stats.sacksReceived}'),
          _buildCompactStatCard('FUM', '${stats.fumbles}'),
          _buildCompactStatCard('FALTAS', '${stats.fouls}'),
          _buildCompactStatCard('TD', '${stats.touchdowns}'),
          _buildCompactStatCard('NO PAT', '${stats.noPat}'),
          _buildCompactStatCard('1PT', '${stats.pat1}'),
          _buildCompactStatCard('2PT', '${stats.pat2}'),
          _buildCompactStatCard('FLAG', '${stats.flagPulls}'),
          _buildCompactStatCard('INT', '${stats.interceptions}'),
          _buildCompactStatCard('BATTED', '${stats.batted}'),
          _buildCompactStatCard('SAFETY', '${stats.safeties}'),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
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
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.nflGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsList(List<PlayerStatsAggregate> stats) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '#${stat.dorsal}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.playerName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'YDS: ${stat.yards} | PASE: ${stat.passes} | CARR: ${stat.runs} | TD: ${stat.touchdowns} | SACK: ${stat.sacks} | FUM: ${stat.fumbles} | FAL: ${stat.fouls} | FLAG: ${stat.flagPulls} | INT: ${stat.interceptions} | BAT: ${stat.batted} | SAF: ${stat.safeties}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${stat.points} PTS',
                style: const TextStyle(
                  color: AppColors.nflGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _resolveOwnTeamId() {
    if (players.isNotEmpty) {
      return players.first.teamId;
    }
    if (match.locationType == LocationType.local) {
      return 'HOME_TEAM';
    }
    return 'AWAY_TEAM';
  }

  String _resolveOpponentTeamId() {
    if (opponentPlayers.isNotEmpty) {
      return opponentPlayers.first.teamId;
    }
    return canonicalizeTeamReference(match.opponentId, {
      match.opponentId: opponentTeamName,
    });
  }

  void _copyStatsToClipboard(BuildContext context) {
    final isUserHome = match.locationType == LocationType.local;
    final ownTeamId = _resolveOwnTeamId();
    final opponentTeamId = _resolveOpponentTeamId();
    final aggregated = aggregateStats(
      matches: [match],
      plays: plays,
      ownTeamId: ownTeamId,
      ownTeamName: ownTeamName,
      teamNamesById: {opponentTeamId: opponentTeamName},
      players: [...players, ...opponentPlayers],
    );
    final teamStatsByRef = {
      for (final stats in aggregated.teamStats) stats.teamRef: stats,
    };
    final playerStatsByRef = <String, List<PlayerStatsAggregate>>{};
    for (final playerStat in aggregated.playerStats) {
      playerStatsByRef
          .putIfAbsent(playerStat.teamRef, () => [])
          .add(playerStat);
    }
    final homeTeamRef = isUserHome ? ownTeamId : opponentTeamId;
    final awayTeamRef = isUserHome ? opponentTeamId : ownTeamId;

    final buffer = StringBuffer();
    buffer.writeln(
      'BOX SCORE - ${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}',
    );
    buffer.writeln('---------------------------------------------------------');
    buffer.writeln('RESULTADO: ${match.homeScore} - ${match.awayScore}');
    buffer.writeln('---------------------------------------------------------');

    void writeTeam(
      String name,
      TeamStatsAggregate? tStats,
      List<PlayerStatsAggregate> pStats,
    ) {
      buffer.writeln('EQUIPO: ${name.toUpperCase()}');
      if (tStats != null) {
        buffer.writeln(
          'Yards: ${tStats.totalYards} | Pase: ${tStats.passes} | Carrera: ${tStats.runs} | Sack: ${tStats.sacks} | Sack Rec: ${tStats.sacksReceived} | Fumble: ${tStats.fumbles} | Falta: ${tStats.fouls} | TD: ${tStats.touchdowns} | No PAT: ${tStats.noPat} | 1PT: ${tStats.pat1} | 2PT: ${tStats.pat2} | Flag: ${tStats.flagPulls} | INT: ${tStats.interceptions} | Batted: ${tStats.batted} | Safety: ${tStats.safeties}',
        );
      }
      if (pStats.isNotEmpty) {
        buffer.writeln('ESTADÍSTICAS JUGADORES:');
        for (var s in pStats) {
          buffer.writeln(
            '  #${s.dorsal} ${s.playerName}: ${s.points} PTS | ${s.yards} YDS | PASE ${s.passes} | CARR ${s.runs} | SACK ${s.sacks} | FUM ${s.fumbles} | FAL ${s.fouls} | TD ${s.touchdowns} | 1PT ${s.pat1} | 2PT ${s.pat2} | FLAG ${s.flagPulls} | INT ${s.interceptions} | BAT ${s.batted} | SAF ${s.safeties}',
          );
        }
      }
      buffer.writeln(
        '---------------------------------------------------------',
      );
    }

    writeTeam(
      isUserHome ? ownTeamName : opponentTeamName,
      teamStatsByRef[homeTeamRef],
      playerStatsByRef[homeTeamRef] ?? const [],
    );
    writeTeam(
      isUserHome ? opponentTeamName : ownTeamName,
      teamStatsByRef[awayTeamRef],
      playerStatsByRef[awayTeamRef] ?? const [],
    );

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    FeedbackUtils.showSuccess(context, 'Estadísticas copiadas al portapapeles');
  }
}
