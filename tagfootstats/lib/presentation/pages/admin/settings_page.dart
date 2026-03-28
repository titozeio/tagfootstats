import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/fake_data_generator.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AJUSTES')),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final ownTeamId = state is AppReady ? state.ownTeam.id : null;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const ListTile(
                leading: Icon(Icons.palette),
                title: Text('APARIENCIA'),
                subtitle: Text('Tema oscuro activo'),
              ),
              const ListTile(
                leading: Icon(Icons.language),
                title: Text('IDIOMA'),
                subtitle: Text('Español (Predeterminado)'),
              ),
              const Divider(),
              _buildSectionTitle('AYUDAS Y DEBUG'),
              ListTile(
                leading: const Icon(
                  Icons.auto_fix_high,
                  color: AppColors.nflGold,
                ),
                title: const Text('GENERAR DATOS DE PRUEBA'),
                subtitle: const Text(
                  'Crea equipos, jugadores y partidos falsos',
                ),
                onTap: ownTeamId == null
                    ? null
                    : () => _generateFakeData(context, ownTeamId),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_sweep,
                  color: AppColors.accentRed,
                ),
                title: const Text('BORRAR TODAS LAS ESTADÍSTICAS'),
                subtitle: const Text(
                  'Elimina partidos y jugadas definitivamente',
                ),
                onTap: () => _confirmAndClearData(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('ACERCA DE'),
                subtitle: const Text('TagFootStats v1.0.0'),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.nflGold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _generateFakeData(BuildContext context, String teamId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FakeDataGenerator.generateAll(
        context,
        teamRepo: context.read<TeamRepository>(),
        playerRepo: context.read<PlayerRepository>(),
        matchRepo: context.read<MatchRepository>(),
        playRepo: context.read<PlayRepository>(),
        tournamentRepo: context.read<TournamentRepository>(),
        currentTeamId: teamId,
      );
      if (context.mounted) Navigator.pop(context); // Close loading
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('DATOS DE PRUEBA GENERADOS CORRECTAMENTE'),
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('ERROR: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  Future<void> _confirmAndClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿BORRAR TODO?'),
        content: const Text(
          'Se eliminarán todos los partidos y jugadas. Los equipos y jugadores se mantendrán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'BORRAR',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        await FakeDataGenerator.deleteAllStats(
          matchRepo: context.read<MatchRepository>(),
          playRepo: context.read<PlayRepository>(),
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('ESTADÍSTICAS BORRADAS')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('ERROR: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }
}
