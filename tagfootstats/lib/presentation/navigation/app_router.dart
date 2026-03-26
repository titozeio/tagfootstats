import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/entities/team.dart';

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
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/setup-team',
        builder: (context, state) => const TeamFormPage(isInitialSetup: true),
      ),
      GoRoute(
        path: '/match/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MatchPage(matchId: id);
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
        builder: (context, state) => const MatchFormPage(),
      ),
    ],
  );
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
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
