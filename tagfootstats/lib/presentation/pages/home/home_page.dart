import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import '../../bloc/app/app_bloc.dart';
import '../../widgets/match_summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TAG FOOT STATS'),
        leading: const Icon(Icons.sports_football, color: AppColors.nflGold),
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is! AppReady) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuickActions(context, state),
                    const SizedBox(height: 32),
                    _buildTeamStats(context, state),
                    const SizedBox(height: 32),
                    _buildLastMatchResult(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.push('/matches/new'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.nflGold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.play_circle_fill, size: 28),
          label: const Text(
            'REGISTRAR PARTIDO',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/stats/advanced'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.nflGold,
            side: const BorderSide(color: AppColors.nflGold),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.analytics),
          label: const Text(
            'ESTADÍSTICAS AVANZADAS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamStats(BuildContext context, AppReady state) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        context.read<MatchRepository>().getMatches(),
        context.read<TeamRepository>().getTeams(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final matches = (snapshot.data![0] as List<entity.Match>)
            .where((match) => hasValidOpponentReference(match.opponentId))
            .toList();
        int wins = 0;
        int losses = 0;
        int pointsFor = 0;
        int pointsAgainst = 0;

        for (var m in matches) {
          final isHome = m.locationType == entity.LocationType.local;
          final isAway = m.locationType == entity.LocationType.visitante;

          pointsFor += isHome ? m.homeScore : m.awayScore;
          pointsAgainst += isHome ? m.awayScore : m.homeScore;

          if (m.homeScore == m.awayScore) continue;

          if (isHome) {
            m.homeScore > m.awayScore ? wins++ : losses++;
          } else if (isAway) {
            m.awayScore > m.homeScore ? wins++ : losses++;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.nflGold.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'team_logo_${state.ownTeam.id}',
                    child: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue,
                      backgroundImage:
                          (state.ownTeam.logoUrl != null &&
                              state.ownTeam.logoUrl!.isNotEmpty)
                          ? NetworkImage(state.ownTeam.logoUrl!)
                          : null,
                      radius: 24,
                      child:
                          (state.ownTeam.logoUrl == null ||
                              state.ownTeam.logoUrl!.isEmpty)
                          ? const Icon(Icons.groups, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.ownTeam.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'ESTADÍSTICAS DE TEMPORADA',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$wins - $losses',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: AppColors.nflGold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('PUNTOS A FAVOR', pointsFor.toString()),
                  _buildStatItem('PUNTOS EN CONTRA', pointsAgainst.toString()),
                  _buildStatItem(
                    'DIFERENCIA',
                    (pointsFor - pointsAgainst).toString(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLastMatchResult(BuildContext context, AppReady state) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        context.read<MatchRepository>().getMatches(),
        context.read<TeamRepository>().getTeams(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final matches =
            (snapshot.data![0] as List<entity.Match>)
                .where((match) => hasValidOpponentReference(match.opponentId))
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        if (matches.isEmpty) {
          return const SizedBox.shrink();
        }

        final teams = snapshot.data![1] as List<dynamic>;
        final teamNames = {
          for (final team in teams) team.id as String: team.name as String,
        };
        final lastMatch = matches.last;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ÚLTIMO PARTIDO',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => context.push('/match/${lastMatch.id}'),
              borderRadius: BorderRadius.circular(12),
              child: MatchSummaryCard(
                match: lastMatch,
                ownTeam: state.ownTeam,
                opponentName: resolveTeamName(lastMatch.opponentId, teamNames),
              ),
            ),
          ],
        );
      },
    );
  }
}
