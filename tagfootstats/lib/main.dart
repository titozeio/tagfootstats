import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_theme.dart';
import 'package:tagfootstats/data/repositories/firestore_match_repository.dart';
import 'package:tagfootstats/data/repositories/firestore_play_repository.dart';
import 'package:tagfootstats/data/repositories/firestore_team_repository.dart';
import 'package:tagfootstats/data/repositories/firestore_tournament_repository.dart';
import 'package:tagfootstats/data/repositories/firestore_player_repository.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/firebase_options.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';
import 'package:tagfootstats/presentation/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TournamentRepository>(
          create: (context) => FirestoreTournamentRepository(),
        ),
        RepositoryProvider<TeamRepository>(
          create: (context) => FirestoreTeamRepository(),
        ),
        RepositoryProvider<PlayerRepository>(
          create: (context) => FirestorePlayerRepository(),
        ),
        RepositoryProvider<MatchRepository>(
          create: (context) => FirestoreMatchRepository(),
        ),
        RepositoryProvider<PlayRepository>(
          create: (context) => FirestorePlayRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            AppBloc(teamRepository: context.read<TeamRepository>())
              ..add(InitializeApp()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AppBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TagFootStats',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.router,
    );
  }
}
