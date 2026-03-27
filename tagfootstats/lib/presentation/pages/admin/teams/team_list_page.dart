import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EQUIPOS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teams/new'),
        label: const Text('NUEVO EQUIPO'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Team>>(
        future: context.read<TeamRepository>().getTeams(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty)
            return const Center(child: Text('No se han encontrado equipos.'));

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
                  leading: CircleAvatar(
                    backgroundColor: team.isOwnTeam
                        ? AppColors.nflGold
                        : AppColors.primaryBlue,
                    backgroundImage: (team.logoUrl != null && team.logoUrl!.isNotEmpty)
                        ? NetworkImage(team.logoUrl!)
                        : null,
                    child: (team.logoUrl == null || team.logoUrl!.isEmpty)
                        ? Icon(
                            team.isOwnTeam ? Icons.star : Icons.group,
                            color: team.isOwnTeam ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          team.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (team.shortName != null && team.shortName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            team.shortName!,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                  subtitle: team.isOwnTeam
                      ? const Text(
                          'EQUIPO PRINCIPAL',
                          style: TextStyle(
                            color: AppColors.nflGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        )
                      : const Text('EQUIPO RIVAL', style: TextStyle(fontSize: 10)),
                  trailing: team.isOwnTeam
                      ? const Icon(Icons.check_circle, color: AppColors.nflGold)
                      : IconButton(
                          icon: const Icon(Icons.star_border, color: Colors.grey),
                          onPressed: () async {
                            await context.read<TeamRepository>().setAsOwnTeam(team.id);
                            // Refresh
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${team.name} ahora es tu equipo')),
                              );
                              // Trigger state update if using Bloc, or just force rebuild
                              context.read<AppBloc>().add(InitializeApp());
                            }
                          },
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
