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
            labelColor: AppColors.nflGold,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.nflGold,
            tabs: [
              Tab(text: 'EQUIPO'),
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
    int totalOffFumbles = 0;
    int totalOffInts = 0;
    int totalOffTDs = 0;

    for (var p in plays) {
      if (p.phase == PlayPhase.ataque) {
        offPlaysCount++;
        totalOffPoints += p.points;
        totalOffYards += p.yardas;
        if (p.yardas > 0 || p.points > 0) successfulOffPlays++;
        if (p.points >= 6) totalOffTDs++;
        
        if (p.action == 'PASE') {
          totalPasses++;
          if (p.outcome == 'COMPLETO') completedPasses++;
          if (p.outcome == 'INTERCEPTADO') totalOffInts++;
        } else if (p.action == 'CARRERA') {
          totalRuns++;
        } else if (p.action == 'FUMBLE') {
          totalOffFumbles++;
        }
      } else if (p.phase == PlayPhase.defensa) {
        if (p.action == 'SACK') totalDefSacks++;
        if (p.action == 'INTERCEPCIÓN') totalDefInts++;
        // We lack fumbles in def phase grid for now, but we can assume from plays if needed
      }
    }

    final avgPpg = matches.isEmpty ? 0 : totalOffPoints / matches.length;
    final ypp = offPlaysCount == 0 ? 0 : totalOffYards / offPlaysCount;
    final successRate = offPlaysCount == 0 ? 0 : (successfulOffPlays / offPlaysCount) * 100;
    final compPct = totalPasses == 0 ? 0 : (completedPasses / totalPasses) * 100;
    final tdRate = offPlaysCount == 0 ? 0 : (totalOffTDs / offPlaysCount) * 100;
    final turnoverDiff = (totalDefInts) - (totalOffInts + totalOffFumbles);

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
              Expanded(child: _buildStatCard('TD RATE', '${tdRate.toStringAsFixed(1)}%', 'TDs por jugada')),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('DIFF TURNOVERS', (turnoverDiff > 0 ? '+$turnoverDiff' : turnoverDiff.toString()), 'Balones recuperados/perdidos')),
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

class _PlayerStatsTab extends StatefulWidget {
  final List<Player> players;
  final List<Play> plays;

  const _PlayerStatsTab({required this.players, required this.plays});

  @override
  State<_PlayerStatsTab> createState() => _PlayerStatsTabState();
}

class _PlayerStatsTabState extends State<_PlayerStatsTab> {
  int _sortColumnIndex = 1;
  bool _sortAscending = false;
  late List<_PlayerStats> _statsList;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  void _calculateStats() {
    final Map<String, _PlayerStats> statsMap = {};
    for (var p in widget.players) {
      statsMap[p.id] = _PlayerStats(
        name: '${p.firstName} ${p.lastName}',
        dorsal: p.dorsal,
        photoUrl: p.photoUrl,
      );
    }

    final totalTeamPlays = widget.plays.length;

    for (var p in widget.plays) {
      for (var playerId in p.involvedPlayerIds) {
        if (statsMap.containsKey(playerId)) {
          final s = statsMap[playerId]!;
          s.totalInvolvement++;
          s.yards += p.yardas;
          s.points += p.points;
          if (p.action == 'SACK') s.sacks++;
          if (p.action == 'INTERCEPCIÓN') s.ints++;
          if (p.action == 'FLAG QUITADO') s.pulls++;
        }
      }
    }

    _statsList = statsMap.values.toList();
    for (var s in _statsList) {
      s.targetShare = totalTeamPlays == 0 ? 0 : (s.totalInvolvement / totalTeamPlays) * 100;
    }
    _sort(1, false);
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _statsList.sort((a, b) {
        dynamic aValue;
        dynamic bValue;
        switch (columnIndex) {
          case 0: aValue = a.name; bValue = b.name; break;
          case 1: aValue = a.points; bValue = b.points; break;
          case 2: aValue = a.yards; bValue = b.yards; break;
          case 3: aValue = a.pulls; bValue = b.pulls; break;
          case 4: aValue = a.ints; bValue = b.ints; break;
          case 5: aValue = a.sacks; bValue = b.sacks; break;
          case 6: aValue = a.targetShare; bValue = b.targetShare; break;
          default: aValue = a.points; bValue = b.points; break;
        }
        return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columnSpacing: 64,
                horizontalMargin: 24,
                headingRowColor: WidgetStateProperty.all(Colors.white10),
              columns: [
                DataColumn(label: const Text('JUGADOR'), onSort: _sort),
                DataColumn(label: const Text('PTS'), numeric: true, onSort: _sort),
                DataColumn(label: const Text('YDS'), numeric: true, onSort: _sort),
                DataColumn(label: const Text('PULLS'), numeric: true, onSort: _sort),
                DataColumn(label: const Text('INT'), numeric: true, onSort: _sort),
                DataColumn(label: const Text('SACK'), numeric: true, onSort: _sort),
                DataColumn(label: const Text('SHARE%'), numeric: true, onSort: _sort),
              ],
              rows: _statsList.map((s) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white12,
                            child: ClipOval(
                              child: (s.photoUrl != null && s.photoUrl!.trim().isNotEmpty)
                                  ? Image.network(
                                      s.photoUrl!.trim(),
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
                                s.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              Text(
                                '#${s.dorsal}',
                                style: const TextStyle(fontSize: 9, color: AppColors.nflGold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(s.points.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green))),
                    DataCell(Text(s.yards.toString())),
                    DataCell(Text(s.pulls.toString())),
                    DataCell(Text(s.ints.toString(), style: const TextStyle(color: Colors.orange))),
                    DataCell(Text(s.sacks.toString())),
                    DataCell(Text('${s.targetShare.toStringAsFixed(1)}%')),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}
}

class _PlayerStats {
  final String name;
  final int dorsal;
  final String? photoUrl;
  int totalInvolvement = 0;
  int yards = 0;
  int points = 0;
  int sacks = 0;
  int pulls = 0;
  int ints = 0;
  double targetShare = 0;

  _PlayerStats({required this.name, required this.dorsal, this.photoUrl});
}
