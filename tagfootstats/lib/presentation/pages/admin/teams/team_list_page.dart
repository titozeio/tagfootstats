import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TEAMS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teams/new'),
        label: const Text('NEW TEAM'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Team>>(
        future: context.read<TeamRepository>().getTeams(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty)
            return const Center(child: Text('No teams found.'));

          final teams = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];

              return Card(
                color: AppColors.surfaceDark,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => context.push('/teams/${team.id}'),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  title: Text(
                    team.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: team.isOwnTeam
                      ? const Text(
                          'YOUR TEAM',
                          style: TextStyle(
                            color: AppColors.nflGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
