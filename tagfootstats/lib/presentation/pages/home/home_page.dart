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

          final isDesktop = MediaQuery.of(context).size.width > 700;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLastMatchResult(context, state),
                    const SizedBox(height: 32),
                    _buildMainMenu(context, isDesktop),
                  ],
                ),
              ),
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

        // Sort matches by date (assuming id or some field indicates chronological order, 
        // ideally matches have a date field, let's assume we take the first for now as per current logic
        // but adding importance to it being interactive)
        final lastMatch = snapshot.data!.first;

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
              child: MatchSummaryCard(match: lastMatch, ownTeam: state.ownTeam),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainMenu(BuildContext context, bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.2 : 1.5,
      children: [
        _buildMenuButton(
          context,
          'TORNEOS',
          Icons.emoji_events,
          '/tournaments',
        ),
        _buildMenuButton(context, 'EQUIPOS', Icons.groups, '/teams'),
        _buildMenuButton(context, 'JUGADORES', Icons.person, '/players'),
        _buildMenuButton(context, 'PARTIDOS', Icons.scoreboard, '/matches'),
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
      borderRadius: BorderRadius.circular(12),
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
