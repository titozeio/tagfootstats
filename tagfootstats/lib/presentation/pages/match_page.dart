import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
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
        matchRepository: context.read<MatchRepository>(),
        playRepository: context.read<PlayRepository>(),
        playerRepository: context.read<PlayerRepository>(),
        teamRepository: context.read<TeamRepository>(),
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
        title: const Text('GRABACIÓN DEL PARTIDO'),
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
                      homeTeamName: 'TU EQUIPO',
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
                      child: const Text('INICIALIZAR PARTIDO DE PRUEBA'),
                    ),
                ],
              ),
            );
          }
          return const Center(child: Text('Inicializa un partido para empezar.'));
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
        ).showSnackBar(SnackBar(content: Text('Error al inicializar: $e')));
      }
    }
  }

  Widget _buildMobileLayout(BuildContext context, MatchLoaded state) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sports_football), text: 'ATAQUE'),
              Tab(icon: Icon(Icons.shield), text: 'DEFENSA'),
            ],
            indicatorColor: AppColors.nflGold,
            labelColor: AppColors.nflGold,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPhasePanel(context, state, PlayPhase.ataque),
                _buildPhasePanel(context, state, PlayPhase.defensa),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, MatchLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'REGISTRO DEL PARTIDO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(child: _buildPlayList(state)),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.sports_football), text: 'ATAQUE'),
                    Tab(icon: Icon(Icons.shield), text: 'DEFENSA'),
                  ],
                  indicatorColor: AppColors.nflGold,
                  labelColor: AppColors.nflGold,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPhasePanel(context, state, PlayPhase.ataque),
                      _buildPhasePanel(context, state, PlayPhase.defensa),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhasePanel(
    BuildContext context,
    MatchLoaded state,
    PlayPhase phase,
  ) {
    return PlayEntryForm(
      phase: phase,
      players: state.players,
      onPlayAdded: (action, outcome, points, yardas, players) {
        _onPlayAdded(
          context,
          state.match.id,
          phase,
          action,
          outcome,
          points,
          yardas,
          players,
        );
      },
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
    int yardas,
    List<String> players,
  ) {
    final play = Play(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      phase: phase,
      minute: 0,
      action: action,
      outcome: outcome,
      points: points,
      yardas: yardas,
      involvedPlayerIds: players,
    );
    context.read<MatchBloc>().add(AddPlayEvent(play));
  }
}
