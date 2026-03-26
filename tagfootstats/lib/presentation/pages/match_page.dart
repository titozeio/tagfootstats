import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/usecases/add_play_to_match.dart';
import 'package:tagfootstats/presentation/bloc/match/match_bloc.dart';
import 'package:tagfootstats/presentation/widgets/play_entry_form.dart';
import 'package:tagfootstats/presentation/widgets/scoreboard_widget.dart';

class MatchPage extends StatelessWidget {
  final String matchId;

  const MatchPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    // Ideally these would be provided by a Dependency Injection container
    final matchRepository = context.read<MatchRepository>();
    final playRepository = context.read<PlayRepository>();
    final addPlayToMatch = AddPlayToMatch(playRepository, matchRepository);

    return BlocProvider(
      create: (context) => MatchBloc(
        matchRepository: matchRepository,
        playRepository: playRepository,
        addPlayToMatch: addPlayToMatch,
      )..add(LoadMatch(matchId)),
      child: const MatchView(),
    );
  }
}

class MatchView extends StatelessWidget {
  const MatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MATCH RECORDING'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MatchLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;

                return Column(
                  children: [
                    ScoreboardWidget(
                      homeTeamName: 'OWN TEAM',
                      awayTeamName: state.match.opponentId,
                      homeScore: state.match.homeScore,
                      awayScore: state.match.awayScore,
                    ),
                    Expanded(
                      child: isDesktop
                          ? _buildDesktopLayout(context, state)
                          : _buildMobileLayout(context, state),
                    ),
                  ],
                );
              },
            );
          } else if (state is MatchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.accentRed,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.message.contains('not found'))
                    ElevatedButton(
                      onPressed: () => _initializeDemoMatch(context),
                      child: const Text('INITIALIZE DEMO MATCH'),
                    ),
                ],
              ),
            );
          }
          return const Center(child: Text('Initialize a match to start.'));
        },
      ),
    );
  }

  Future<void> _initializeDemoMatch(BuildContext context) async {
    final matchRepository = context.read<MatchRepository>();
    final demoMatch = entity.Match(
      id: 'demo_match_1',
      tournamentId: 'demo_tournament',
      opponentId: 'SHARKS',
      dateTime: DateTime.now(),
      locationType: entity.LocationType.local,
      homeScore: 0,
      awayScore: 0,
    );

    try {
      await matchRepository.saveMatch(demoMatch);
      // Reload the match
      if (context.mounted) {
        context.read<MatchBloc>().add(const LoadMatch('demo_match_1'));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing: $e')));
      }
    }
  }

  Widget _buildMobileLayout(BuildContext context, MatchLoaded state) {
    return Column(
      children: [
        Expanded(child: _buildPlayList(state)),
        PlayEntryForm(
          onPlayAdded: (phase, action, outcome, points) {
            _onPlayAdded(
              context,
              state.match.id,
              phase,
              action,
              outcome,
              points,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, MatchLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'PLAY FEED',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Expanded(child: _buildPlayList(state)),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: PlayEntryForm(
              onPlayAdded: (phase, action, outcome, points) {
                _onPlayAdded(
                  context,
                  state.match.id,
                  phase,
                  action,
                  outcome,
                  points,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayList(MatchLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.plays.length,
      itemBuilder: (context, index) {
        final play = state.plays[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: play.phase == PlayPhase.ataque
                ? AppColors.primaryBlue
                : AppColors.accentRed,
            child: Text(
              play.points.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text('${play.action} - ${play.outcome}'),
          subtitle: Text(
            '${play.phase.name.toUpperCase()} | MIN: ${play.minute}',
          ),
        );
      },
    );
  }

  void _onPlayAdded(
    BuildContext context,
    String matchId,
    PlayPhase phase,
    String action,
    String outcome,
    int points,
  ) {
    final play = Play(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      phase: phase,
      minute: 0, // Should be dynamic
      action: action,
      outcome: outcome,
      points: points,
    );
    context.read<MatchBloc>().add(AddPlayEvent(play));
  }
}
