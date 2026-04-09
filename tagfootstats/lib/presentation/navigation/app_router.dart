import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';
import 'package:tagfootstats/presentation/pages/home/home_page.dart';
import 'package:tagfootstats/presentation/pages/match_page.dart';
import 'package:tagfootstats/presentation/pages/splash_page.dart';
import 'package:tagfootstats/presentation/pages/admin/team_form_page.dart';
import 'package:tagfootstats/presentation/pages/admin/tournaments/tournament_list_page.dart';
import 'package:tagfootstats/presentation/pages/admin/tournaments/tournament_form_page.dart';
import 'package:tagfootstats/presentation/pages/admin/teams/team_list_page.dart';
import 'package:tagfootstats/presentation/pages/admin/players/player_list_page.dart';
import 'package:tagfootstats/presentation/pages/admin/players/player_form_page.dart';
import 'package:tagfootstats/presentation/pages/admin/matches/match_list_page.dart';
import 'package:tagfootstats/presentation/pages/admin/matches/match_form_page.dart';
import 'package:tagfootstats/presentation/pages/admin/settings_page.dart';
import 'package:tagfootstats/presentation/pages/stats/advanced_stats_page.dart';
import 'package:tagfootstats/presentation/pages/stats/match_stats_page.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/presentation/widgets/main_scaffold.dart';

class AppRouter {
  final AppBloc appBloc;

  AppRouter(this.appBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AppBlocListenable(appBloc),
    redirect: (context, state) {
      final appState = appBloc.state;

      if (appState is AppInitial ||
          appState is AppLoading ||
          appState is AppError) {
        if (state.matchedLocation == '/splash') return null;
        return '/splash';
      }

      if (appState is AppNoTeam) {
        if (state.matchedLocation == '/setup-team') return null;
        return '/setup-team';
      }

      if (appState is AppReady &&
          (state.matchedLocation == '/setup-team' ||
              state.matchedLocation == '/splash')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/setup-team',
        builder: (context, state) => const TeamFormPage(isInitialSetup: true),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/match/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MatchPage(matchId: id);
            },
          ),
          GoRoute(
            path: '/match/:id/stats',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final appState = appBloc.state;
              final teamId = appState is AppReady ? appState.ownTeam.id : '';
              final ownTeamName = appState is AppReady
                  ? appState.ownTeam.name
                  : 'Mi Equipo';

              return MatchStatsLoader(
                matchId: id,
                teamId: teamId,
                ownTeamName: ownTeamName,
              );
            },
          ),
          GoRoute(
            path: '/tournaments',
            builder: (context, state) => const TournamentListPage(),
          ),
          GoRoute(
            path: '/tournaments/new',
            builder: (context, state) => const TournamentFormPage(),
          ),
          GoRoute(
            path: '/tournaments/:id',
            builder: (context, state) =>
                TournamentFormPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/teams',
            builder: (context, state) => const TeamListPage(),
          ),
          GoRoute(
            path: '/teams/new',
            builder: (context, state) => const TeamFormPage(),
          ),
          GoRoute(
            path: '/teams/:id',
            builder: (context, state) =>
                TeamFormLoader(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/players',
            builder: (context, state) => const PlayerListPage(),
          ),
          GoRoute(
            path: '/players/:teamId',
            builder: (context, state) =>
                PlayerListPage(teamId: state.pathParameters['teamId']),
          ),
          GoRoute(
            path: '/player/new/:teamId',
            builder: (context, state) =>
                PlayerFormPage(teamId: state.pathParameters['teamId']),
          ),
          GoRoute(
            path: '/player/:id',
            builder: (context, state) =>
                PlayerFormPage(id: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/matches',
            builder: (context, state) => const MatchListPage(),
          ),
          GoRoute(
            path: '/matches/new',
            builder: (context, state) {
              final tournamentId = state.uri.queryParameters['tournamentId'];
              return MatchFormPage(tournamentId: tournamentId);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/stats/advanced',
            builder: (context, state) => const AdvancedStatsPage(),
          ),
        ],
      ),
    ],
  );
}

class MatchStatsLoader extends StatelessWidget {
  final String matchId;
  final String teamId;
  final String ownTeamName;

  const MatchStatsLoader({
    super.key,
    required this.matchId,
    required this.teamId,
    required this.ownTeamName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _loadData(context).timeout(const Duration(seconds: 15)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('ERROR')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      'ERROR AL CARGAR ESTADÍSTICAS:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('VOLVER'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.nflGold),
                  SizedBox(height: 24),
                  Text(
                    'CARGANDO ESTADÍSTICAS...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            (snapshot.data as List).any((e) => e == null)) {
          return const Scaffold(
            body: Center(child: Text('Datos no encontrados')),
          );
        }

        final data = snapshot.data as List<dynamic>;
        return MatchStatsPage(
          match: data[0] as entity.Match,
          plays: data[1] as List<Play>,
          players: data[2] as List<Player>,
          opponentPlayers: data[3] as List<Player>,
          ownTeamName: ownTeamName,
          opponentTeamName: data[4] as String,
        );
      },
    );
  }

  Future<List<dynamic>> _loadData(BuildContext context) async {
    final matchRepository = context.read<MatchRepository>();
    final playRepository = context.read<PlayRepository>();
    final playerRepository = context.read<PlayerRepository>();
    final teamRepository = context.read<TeamRepository>();

    final match = await matchRepository.getMatchById(matchId);
    final plays = await playRepository.getPlaysByMatch(matchId);
    final ownPlayers = await playerRepository.getPlayersByTeam(teamId);

    if (match == null) {
      return [null, plays, ownPlayers, const <Player>[], 'Contrincante'];
    }

    final teams = await teamRepository.getTeams();
    final teamNamesById = {for (final team in teams) team.id: team.name};
    final opponentTeamRef = canonicalizeTeamReference(
      match.opponentId,
      teamNamesById,
    );
    final opponentPlayers = await playerRepository.getPlayersByTeam(
      opponentTeamRef,
    );
    final opponentTeamName = resolveTeamName(match.opponentId, teamNamesById);

    return [match, plays, ownPlayers, opponentPlayers, opponentTeamName];
  }
}

// Helper to load team before showing form
class TeamFormLoader extends StatelessWidget {
  final String id;
  const TeamFormLoader({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<TeamRepository>().getTeamById(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return TeamFormPage(team: snapshot.data as Team);
      },
    );
  }
}

class _AppBlocListenable extends ChangeNotifier {
  _AppBlocListenable(AppBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
