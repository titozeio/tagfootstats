import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';
import 'package:tagfootstats/presentation/widgets/match_summary_card.dart';

class MatchListPage extends StatelessWidget {
  const MatchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PARTIDOS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/matches/new'),
        label: const Text('NUEVO PARTIDO'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<entity.Match>>(
        future: context.read<MatchRepository>().getMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty)
            return const Center(child: Text('No se han encontrado partidos.'));

          final matches = snapshot.data!;
          final appState = context.read<AppBloc>().state;
          if (appState is! AppReady) return const SizedBox.shrink();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return InkWell(
                onTap: () => context.push('/match/${match.id}'),
                child: MatchSummaryCard(
                  match: match,
                  ownTeam: appState.ownTeam,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
