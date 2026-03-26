import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_theme.dart';
import 'package:tagfootstats/data/repositories/firestore_match_repository.dart';
import 'package:tagfootstats/data/repositories/firestore_play_repository.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/firebase_options.dart';
import 'package:tagfootstats/presentation/pages/match_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MatchRepository>(
          create: (context) => FirestoreMatchRepository(),
        ),
        RepositoryProvider<PlayRepository>(
          create: (context) => FirestorePlayRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'TagFootStats',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        // Using a dummy matchId for demonstration
        home: const MatchPage(matchId: 'demo_match_1'),
      ),
    );
  }
}
