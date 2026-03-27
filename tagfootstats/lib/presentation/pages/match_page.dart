import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';
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
                      timeLeft: _calculateTimeLeft(state.plays),
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

  String _calculateTimeLeft(List<Play> plays) {
    if (plays.isEmpty) return '00:00';
    final maxMin =
        plays.map((p) => p.minute).reduce((a, b) => a > b ? a : b);
    return '${maxMin.toString().padLeft(2, '0')}:00';
  }

  Widget _buildMobileLayout(BuildContext context, MatchLoaded state) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sports_football), text: 'ATAQUE'),
              Tab(icon: Icon(Icons.shield), text: 'DEFENSA'),
              Tab(icon: Icon(Icons.list), text: 'JUGADAS'),
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
                _buildPlayList(state),
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
      homeScore: state.match.homeScore,
      awayScore: state.match.awayScore,
      onPlayAdded: (action, outcome, points, yardas, minute, down, players) {
        _onPlayAdded(
          context,
          state.match.id,
          phase,
          action,
          outcome,
          points,
          yardas,
          minute,
          down,
          players,
        );
      },
    );
  }

  Widget _buildPlayList(MatchLoaded state) {
    // Sort plays by minute chronologically as requested
    final sortedPlays = List<Play>.from(state.plays)
      ..sort((a, b) => a.minute.compareTo(b.minute));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedPlays.length,
      itemBuilder: (context, index) {
        final play = sortedPlays[index];
        final isOffense = play.phase == PlayPhase.ataque;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: AppColors.surfaceDark,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isOffense ? AppColors.primaryBlue : AppColors.accentRed,
              child: Text(
                play.points > 0 ? '+${play.points}' : '0',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              '${play.action} - ${play.outcome}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIN: ${play.minute} | ${play.down != null ? "${play.down}º DOWN | " : ""}${play.yardas} YDS | ${isOffense ? "ATAQUE" : "DEFENSA"}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (play.involvedPlayerIds.isNotEmpty)
                  FutureBuilder(
                    future: Future.wait(play.involvedPlayerIds.map(
                      (id) => context.read<PlayerRepository>().getPlayerById(id),
                    )),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final players = snapshot.data!.whereType<Player>().toList();
                        return Text(
                          'JUGADORES: ${players.map((p) => "#${p.dorsal}").join(" ")}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.nflGold,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
            trailing: play.points > 0
                ? const Icon(Icons.stars, color: AppColors.nflGold)
                : null,
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
    int minute,
    int? down,
    List<String> players,
  ) {
    final play = Play(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      phase: phase,
      minute: minute,
      down: down,
      action: action,
      outcome: outcome,
      points: points,
      yardas: yardas,
      involvedPlayerIds: players,
    );
    context.read<MatchBloc>().add(AddPlayEvent(play));
  }
}
