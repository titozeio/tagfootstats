import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity_match;
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
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
            tabs: [
              Tab(text: 'EQUIPO'),
              Tab(text: 'JUGADORES'),
            ],
            indicatorColor: AppColors.nflGold,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is! AppReady) {
              return const Center(child: CircularProgressIndicator());
            }
            return _StatsLoader(ownTeamId: state.ownTeam.id);
          },
        ),
      ),
    );
  }
}

class _StatsLoader extends StatelessWidget {
  final String ownTeamId;
  const _StatsLoader({required this.ownTeamId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as Map<String, dynamic>;
        final matches = data['matches'] as List<entity_match.Match>;
        final plays = data['plays'] as List<Play>;
        final players = data['players'] as List<Player>;

        return TabBarView(
          children: [
            _TeamStatsTab(matches: matches, plays: plays),
            _PlayerStatsTab(players: players, plays: plays),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchData(BuildContext context) async {
    final matches = await context.read<MatchRepository>().getMatches();
    // Filter matches where ownTeamId is home or away
    // In current data model, we assume matches in Repository are all relevant or we filter by Team
    // Actually our Match has opponentId and locationType
    // We'll collect all match IDs
    final matchIds = matches.map((m) => m.id).toList();
    final plays = await context.read<PlayRepository>().getPlaysByMatches(matchIds);
    final players = await context.read<PlayerRepository>().getPlayersByTeam(ownTeamId);

    return {
      'matches': matches,
      'plays': plays,
      'players': players,
    };
  }
}

class _TeamStatsTab extends StatelessWidget {
  final List<entity_match.Match> matches;
  final List<Play> plays;

  const _TeamStatsTab({required this.matches, required this.plays});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const Center(child: Text('No hay partidos registrados'));

    // Compute Stats
    int totalOffPoints = 0;
    int totalOffYards = 0;
    int offPlaysCount = 0;
    int successfulOffPlays = 0;
    int totalPasses = 0;
    int completedPasses = 0;
    int totalRuns = 0;

    int totalDefSacks = 0;
    int totalDefInts = 0;

    for (var p in plays) {
      if (p.phase == PlayPhase.ataque) {
        offPlaysCount++;
        totalOffPoints += p.points;
        totalOffYards += p.yardas;
        if (p.yardas > 0 || p.points > 0) successfulOffPlays++;
        
        if (p.action == 'PASE') {
          totalPasses++;
          if (p.outcome == 'COMPLETO') completedPasses++;
        } else if (p.action == 'CARRERA') {
          totalRuns++;
        }
      } else if (p.phase == PlayPhase.defensa) {
        if (p.action == 'SACK') totalDefSacks++;
        if (p.action == 'INTERCEPCIÓN') totalDefInts++;
      }
    }

    final avgPpg = matches.isEmpty ? 0 : totalOffPoints / matches.length;
    final ypp = offPlaysCount == 0 ? 0 : totalOffYards / offPlaysCount;
    final successRate = offPlaysCount == 0 ? 0 : (successfulOffPlays / offPlaysCount) * 100;
    final compPct = totalPasses == 0 ? 0 : (completedPasses / totalPasses) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('EFICIENCIA (Success Rate)', '${successRate.toStringAsFixed(1)}%', 'Jugadas con avance')),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('YDS / PLAY', ypp.toStringAsFixed(1), 'Yardas promedio')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('PPG', avgPpg.toStringAsFixed(1), 'Puntos por partido')),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('COMP%', '${compPct.toStringAsFixed(1)}%', '$completedPasses/$totalPasses comp')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('DEFENSA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard('DEF SACKS', totalDefSacks.toString(), 'Total Sacks')),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('DEF INTs', totalDefInts.toString(), 'Intercepciones')),
            ],
          ),
          const SizedBox(height: 24),
          _buildPlaytypeChart(totalPasses, totalRuns),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.nflGold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPlaytypeChart(int passes, int runs) {
    final total = passes + runs;
    if (total == 0) return const SizedBox.shrink();
    final passPct = (passes / total) * 100;
    final runPct = (runs / total) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const Text('MIX DE JUGADAS (PASE VS CARRERA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: passes, child: Container(height: 12, color: AppColors.primaryBlue)),
              Expanded(flex: runs, child: Container(height: 12, color: AppColors.accentRed)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PASE: ${passPct.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              Text('CARRERA: ${runPct.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerStatsTab extends StatelessWidget {
  final List<Player> players;
  final List<Play> plays;

  const _PlayerStatsTab({required this.players, required this.plays});

  @override
  Widget build(BuildContext context) {
    // Collect stats per player
    final Map<String, _PlayerStats> statsMap = {};
    for (var p in players) {
      statsMap[p.id] = _PlayerStats(name: '${p.firstName} ${p.lastName}', dorsal: p.dorsal);
    }

    for (var p in plays) {
      for (var playerId in p.involvedPlayerIds) {
        if (statsMap.containsKey(playerId)) {
          final s = statsMap[playerId]!;
          s.plays++;
          s.yards += p.yardas;
          s.points += p.points;
          if (p.action == 'SACK') s.sacks++;
          if (p.action == 'INTERCEPCIÓN') s.ints++;
          if (p.action == 'FLAG QUITADO') s.pulls++;
          if (p.action == 'PASE' && p.outcome == 'COMPLETO') s.receptions++; // Simple assumption
        }
      }
    }

    final statsList = statsMap.values.toList()..sort((a, b) => b.points.compareTo(a.points));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.black38),
          columns: const [
            DataColumn(label: Text('JUGADOR')),
            DataColumn(label: Text('PTS')),
            DataColumn(label: Text('YDS')),
            DataColumn(label: Text('PULLS')),
            DataColumn(label: Text('INT')),
            DataColumn(label: Text('SACKS')),
          ],
          rows: statsList.map((s) {
            return DataRow(cells: [
              DataCell(Text('#${s.dorsal} ${s.name}')),
              DataCell(Text(s.points.toString())),
              DataCell(Text(s.yards.toString())),
              DataCell(Text(s.pulls.toString())),
              DataCell(Text(s.ints.toString())),
              DataCell(Text(s.sacks.toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _PlayerStats {
  final String name;
  final int dorsal;
  int plays = 0;
  int yards = 0;
  int points = 0;
  int sacks = 0;
  int pulls = 0;
  int ints = 0;
  int receptions = 0;

  _PlayerStats({required this.name, required this.dorsal});
}
