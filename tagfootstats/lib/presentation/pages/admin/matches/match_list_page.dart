import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/usecases/delete_match_and_plays.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';
import 'package:tagfootstats/presentation/widgets/match_summary_card.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';

class MatchListPage extends StatefulWidget {
  const MatchListPage({super.key});

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List<entity.Match>? _matches;
  Map<String, String> _teamNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final matchRepository = context.read<MatchRepository>();
    final teamRepository = context.read<TeamRepository>();

    try {
      final matches = await matchRepository.getMatches();
      final teams = await teamRepository.getTeams();
      final names = {for (var t in teams) t.id: t.name};

      if (mounted) {
        setState(() {
          _matches = matches;
          _teamNames = names;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PARTIDOS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/matches/new'),
        label: const Text('NUEVO PARTIDO'),
        icon: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_matches == null || _matches!.isEmpty) {
      return const Center(child: Text('No se han encontrado partidos.'));
    }

    final appState = context.read<AppBloc>().state;
    if (appState is! AppReady) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matches!.length,
      itemBuilder: (context, index) {
        final match = _matches![index];
        final opponentName = resolveTeamName(match.opponentId, _teamNames);

        return Stack(
          children: [
            InkWell(
              onTap: () => context.push('/match/${match.id}'),
              child: MatchSummaryCard(
                match: match,
                ownTeam: appState.ownTeam,
                opponentName: opponentName,
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: IconButton(
                tooltip: 'Eliminar partido',
                onPressed: () => _confirmDelete(match.id),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.accentRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String matchId) async {
    final matchRepository = context.read<MatchRepository>();
    final playRepository = context.read<PlayRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar partido?'),
        content: const Text(
          'Se eliminarán el partido y todas sus jugadas asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final deleteMatchAndPlays = DeleteMatchAndPlays(
      matchRepository,
      playRepository,
    );
    await deleteMatchAndPlays(matchId);
    if (!mounted) {
      return;
    }
    await _loadData();
  }
}
