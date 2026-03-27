import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/tournament.dart';
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';
import 'package:tagfootstats/presentation/widgets/live_tag.dart';

class TournamentListPage extends StatelessWidget {
  const TournamentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TORNEOS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tournaments/new'),
        label: const Text('NUEVO TORNEO'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Tournament>>(
        future: context.read<TournamentRepository>().getTournaments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty)
            return const Center(child: Text('No se han encontrado torneos.'));

          final tournaments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              final isLive = tournament.endDate.isAfter(DateTime.now());

              return Card(
                color: AppColors.surfaceDark,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => context.push('/tournaments/${tournament.id}'),
                  title: Text(
                    tournament.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${tournament.startDate.day}/${tournament.startDate.month} - ${tournament.endDate.day}/${tournament.endDate.month}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive) const LiveTag(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
