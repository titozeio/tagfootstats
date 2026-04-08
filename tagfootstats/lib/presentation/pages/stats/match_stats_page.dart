import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/feedback_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';

class MatchStatsPage extends StatelessWidget {
  final Match match;
  final List<Play> plays;
  final List<Player> players;
  final String ownTeamName;
  final String opponentTeamName;

  const MatchStatsPage({
    super.key,
    required this.match,
    required this.plays,
    required this.players,
    required this.ownTeamName,
    required this.opponentTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final isUserHome = match.locationType == LocationType.local;
    final homeTeamName = isUserHome ? ownTeamName : opponentTeamName;
    final awayTeamName = isUserHome ? opponentTeamName : ownTeamName;

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
            _buildTeamSection(context, homeTeamName, true), // isHome = true
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(color: Colors.white10, thickness: 2),
            ),
            _buildTeamSection(context, awayTeamName, false), // isHome = false
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

  Widget _buildTeamSection(BuildContext context, String teamName, bool isOwn) {
    final teamStats = _calculateTeamStats(isOwn);
    final playerStats = _calculatePlayerStats(isOwn);

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
                color: isOwn ? AppColors.primaryBlue : AppColors.accentRed,
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
        _buildCompactTeamGrid(teamStats),
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
        ] else if (isOwn) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Sin datos de jugadores propios registrados',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactTeamGrid(Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildCompactStatCard('YDS', '${stats['totalYards']}'),
          _buildCompactStatCard('TD', '${stats['tds']}'),
          _buildCompactStatCard('SACK', '${stats['sacksRec']}'),
          _buildCompactStatCard('INT', '${stats['intsThrow']}'),
          _buildCompactStatCard('FALTAS', '${stats['fouls']}'),
          _buildCompactStatCard('EFF 3/4', '${stats['efficiency']}%'),
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

  Widget _buildPlayerStatsList(List<_PlayerStatRow> stats) {
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
                  '#${stat.player.dorsal}',
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
                      stat.player.fullName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'YDS: ${stat.yards} | TD: ${stat.tds} | SACK: ${stat.sacks} | INT: ${stat.ints}',
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

  Map<String, dynamic> _calculateTeamStats(bool isHome) {
    int totalYards = 0;
    int tds = 0;
    int sacksRec = 0;
    int intsThrow = 0;
    int fouls = 0;
    int totalThirdFourth = 0;
    int successThirdFourth = 0;

    // isHome means "Own Team" in our recording logic.
    // If our team is LOCAL, then isHome == true means LOCAL stats.
    // If our team is VISITANTE, then isHome == true means VISITANTE stats?
    // Actually, match.locationType tells us if we are local.

    final weAreLocal = match.locationType == LocationType.local;
    final isOurTeam = isHome == weAreLocal;

    for (var play in plays) {
      final belongsToThisTeam = isOurTeam
          ? (play.phase == PlayPhase.ataque)
          : (play.phase == PlayPhase.defensa);

      // Note: This logic assumes that if we are in defense, the opponent is in attack.
      // And we attribute the yards of the play to the attacking team.

      if (belongsToThisTeam) {
        totalYards += play.yardas;
        if (play.points == 6) tds++;
        if (play.action == 'SACK') sacksRec++;
        if (play.outcome.contains('INTERCEPTADO')) intsThrow++;
        if (play.action == 'FALTA' && play.penalizingTeamId != null) {
          // If we track penalizingTeamId, we should use it.
          // But for now, let's keep it simple.
          fouls++;
        }
        if (play.down == 3 || play.down == 4) {
          totalThirdFourth++;
          if (play.yardas >= 5) successThirdFourth++;
        }
      }
    }

    return {
      'totalYards': totalYards,
      'tds': tds,
      'sacksRec': sacksRec,
      'intsThrow': intsThrow,
      'fouls': fouls,
      'efficiency': totalThirdFourth == 0
          ? 0
          : (successThirdFourth * 100 / totalThirdFourth).round(),
    };
  }

  List<_PlayerStatRow> _calculatePlayerStats(bool isHome) {
    final weAreLocal = match.locationType == LocationType.local;
    final isOurTeam = isHome == weAreLocal;

    // We only have our own players data for now
    if (!isOurTeam) return [];

    final Map<String, _PlayerStatRow> statsMap = {};

    for (var player in players) {
      statsMap[player.id] = _PlayerStatRow(player: player);
    }

    for (var play in plays) {
      for (var playerId in play.involvedPlayerIds) {
        final stat = statsMap[playerId];
        if (stat != null) {
          stat.yards += play.yardas;
          stat.points += play.points;
          if (play.points == 6) stat.tds++;
          if (play.action == 'SACK') stat.sacks++;
          if (play.outcome.contains('INTERCEPTADO')) stat.ints++;
        }
      }
    }

    return statsMap.values
        .where(
          (s) => s.yards != 0 || s.points != 0 || s.sacks != 0 || s.ints != 0,
        )
        .toList()
      ..sort((a, b) => b.points.compareTo(a.points));
  }

  void _copyStatsToClipboard(BuildContext context) {
    final team1Stats = _calculateTeamStats(true);
    final player1Stats = _calculatePlayerStats(true);
    final team2Stats = _calculateTeamStats(false);
    final player2Stats = _calculatePlayerStats(false);

    final buffer = StringBuffer();
    buffer.writeln(
      'BOX SCORE - ${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}',
    );
    buffer.writeln('---------------------------------------------------------');
    buffer.writeln('RESULTADO: ${match.homeScore} - ${match.awayScore}');
    buffer.writeln('---------------------------------------------------------');

    void writeTeam(
      String name,
      Map<String, dynamic> tStats,
      List<_PlayerStatRow> pStats,
    ) {
      buffer.writeln('EQUIPO: ${name.toUpperCase()}');
      buffer.writeln(
        'Yards: ${tStats['totalYards']} | TD: ${tStats['tds']} | Sacks: ${tStats['sacksRec']} | Int: ${tStats['intsThrow']}',
      );
      if (pStats.isNotEmpty) {
        buffer.writeln('ESTADÍSTICAS JUGADORES:');
        for (var s in pStats) {
          buffer.writeln(
            '  #${s.player.dorsal} ${s.player.fullName}: ${s.points} PTS | ${s.yards} YDS | ${s.tds} TD',
          );
        }
      }
      buffer.writeln(
        '---------------------------------------------------------',
      );
    }

    writeTeam(
      'LOCAL${match.locationType == LocationType.local ? ' (PROPIO)' : ''}',
      team1Stats,
      player1Stats,
    );
    writeTeam(opponentTeamName, team2Stats, player2Stats);

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    FeedbackUtils.showSuccess(context, 'Estadísticas copiadas al portapapeles');
  }
}

class _PlayerStatRow {
  final Player player;
  int yards = 0;
  int points = 0;
  int tds = 0;
  int sacks = 0;
  int ints = 0;

  _PlayerStatRow({required this.player});
}
