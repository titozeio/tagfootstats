import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLastMatchResult(context, state),
                const SizedBox(height: 32),
                _buildMainMenu(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLastMatchResult(BuildContext context, AppReady state) {
    return FutureBuilder<List<entity.Match>>(
      future: context.read<MatchRepository>().getMatches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final lastMatch =
            snapshot.data!.first; // Simple for now, should be sorted

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LAST MATCH',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            MatchSummaryCard(match: lastMatch, ownTeam: state.ownTeam),
          ],
        );
      },
    );
  }

  Widget _buildMainMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMenuButton(
          context,
          'TOURNAMENTS',
          Icons.emoji_events,
          '/tournaments',
        ),
        _buildMenuButton(context, 'TEAMS', Icons.groups, '/teams'),
        _buildMenuButton(context, 'PLAYERS', Icons.person, '/players'),
        _buildMenuButton(context, 'MATCHES', Icons.scoreboard, '/matches'),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.nflGold),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
