import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/play.dart';
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
            return Column(
              children: [
                ScoreboardWidget(
                  homeTeamName: 'OWN TEAM',
                  awayTeamName: state.match.opponentId, // Simplified for now
                  homeScore: state.match.homeScore,
                  awayScore: state.match.awayScore,
                ),
                Expanded(
                  child: ListView.builder(
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
                  ),
                ),
                PlayEntryForm(
                  onPlayAdded: (phase, action, outcome, points) {
                    final play = Play(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      matchId: state.match.id,
                      phase: phase,
                      minute: 0, // Should be dynamic
                      action: action,
                      outcome: outcome,
                      points: points,
                    );
                    context.read<MatchBloc>().add(AddPlayEvent(play));
                  },
                ),
              ],
            );
          } else if (state is MatchError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Initialize a match to start.'));
        },
      ),
    );
  }
}
