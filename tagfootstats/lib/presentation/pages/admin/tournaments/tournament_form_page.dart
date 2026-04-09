import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/tournament.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/usecases/delete_match_and_plays.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';

class TournamentFormPage extends StatefulWidget {
  final String? id;

  const TournamentFormPage({super.key, this.id});

  @override
  State<TournamentFormPage> createState() => _TournamentFormPageState();
}

class _TournamentFormPageState extends State<TournamentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quickTeamController;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TournamentType _type = TournamentType.liga;
  List<String> _teamIds = [];
  List<entity.Match> _matches = [];
  Map<String, String> _teamNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quickTeamController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.id != null) {
      final tournamentRepo = context.read<TournamentRepository>();
      final matchRepo = context.read<MatchRepository>();
      final teamRepo = context.read<TeamRepository>();

      final tournament = await tournamentRepo.getTournamentById(widget.id!);
      final teams = await teamRepo.getTeams();
      if (tournament != null) {
        final matches = await matchRepo.getMatchesByTournament(widget.id!);
        setState(() {
          _nameController.text = tournament.name;
          _startDate = tournament.startDate;
          _endDate = tournament.endDate;
          _type = tournament.type;
          _teamIds = List.from(tournament.teamIds);
          _matches = matches;
          _teamNames = {for (final team in teams) team.id: team.name};
        });
      }
    } else {
      // New tournament: include own team by default
      final appState = context.read<AppBloc>().state;
      if (appState is AppReady) {
        _teamIds = [appState.ownTeam.id];
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'NUEVO TORNEO' : 'EDITAR TORNEO'),
        actions: [
          if (widget.id != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.accentRed),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'NOMBRE DEL TORNEO',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<TournamentType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'TIPO',
                  border: OutlineInputBorder(),
                ),
                items: TournamentType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(height: 24),
              _buildDatePicker(
                'FECHA DE INICIO',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                'FECHA DE FIN',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
              const SizedBox(height: 32),
              const Text(
                'EQUIPOS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._teamIds.map((id) => _buildTeamTile(id)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showAddTeamDialog,
                icon: const Icon(Icons.group_add),
                label: const Text('AÑADIR EQUIPO EXISTENTE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quickTeamController,
                      decoration: const InputDecoration(
                        labelText: 'NOMBRE DE NUEVO EQUIPO RÁPIDO',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addQuickTeam,
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              if (widget.id != null) ...[
                const SizedBox(height: 32),
                const Text(
                  'PARTIDOS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ..._matches.map((m) => _buildMatchTile(m)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddMatchDialog,
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('AÑADIR PARTIDO EXISTENTE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceDark,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createNewMatch,
                        icon: const Icon(Icons.add_box),
                        label: const Text('NUEVO PARTIDO'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.id == null ? 'CREAR TORNEO' : 'GUARDAR CAMBIOS',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTile(String id) {
    return FutureBuilder(
      future: context.read<TeamRepository>().getTeamById(id),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? 'Cargando...';
        return ListTile(
          title: Text(name),
          trailing: IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.accentRed,
            ),
            onPressed: () => setState(() => _teamIds.remove(id)),
          ),
        );
      },
    );
  }

  Future<void> _addQuickTeam() async {
    if (_quickTeamController.text.isEmpty) return;
    final teamRepo = context.read<TeamRepository>();
    final team = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _quickTeamController.text,
    );
    await teamRepo.saveTeam(team);
    setState(() {
      _teamIds.add(team.id);
      _quickTeamController.clear();
    });
  }

  Future<void> _showAddTeamDialog() async {
    final teams = await context.read<TeamRepository>().getTeams();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('SELECCIONAR EQUIPO'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                if (_teamIds.contains(team.id)) return const SizedBox.shrink();
                return ListTile(
                  title: Text(team.name),
                  onTap: () {
                    setState(() => _teamIds.add(team.id));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime current,
    Function(DateTime) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: current,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onPicked(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text('${current.day}/${current.month}/${current.year}'),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final tournament = Tournament(
        id: widget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        startDate: _startDate,
        endDate: _endDate,
        type: _type,
        teamIds: _teamIds,
      );

      final tournamentRepo = context.read<TournamentRepository>();
      await tournamentRepo.saveTournament(tournament);
      if (mounted) context.pop();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿ELIMINAR TORNEO?'),
        content: const Text(
          'ESTA ACCIÓN ES IRREVERSIBLE. TODOS LOS PARTIDOS Y ESTADÍSTICAS ASOCIADOS A ESTE TORNEO SE PERDERÁN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final tournamentRepo = context.read<TournamentRepository>();
      await tournamentRepo.deleteTournament(widget.id!);
      if (mounted) context.pop();
    }
  }

  Widget _buildMatchTile(entity.Match match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/match/${match.id}'),
        leading: const Icon(Icons.scoreboard, color: AppColors.nflGold),
        title: Text('${match.homeScore} - ${match.awayScore}'),
        subtitle: Text(
          'CONTRA ${resolveTeamName(match.opponentId, _teamNames)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.accentRed),
          onPressed: () => _deleteMatch(match.id),
        ),
      ),
    );
  }

  Future<void> _deleteMatch(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿ELIMINAR PARTIDO?'),
        content: const Text('ESTO ELIMINARÁ EL PARTIDO PERMANENTEMENTE.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final deleteMatchAndPlays = DeleteMatchAndPlays(
        context.read<MatchRepository>(),
        context.read<PlayRepository>(),
      );
      await deleteMatchAndPlays(id);
      if (mounted) _loadData();
    }
  }

  Future<void> _showAddMatchDialog() async {
    final allMatches = await context.read<MatchRepository>().getMatches();
    // Filter out matches already in this tournament and matches from other tournaments
    // (A match can only be in one tournament according to the entity)
    final availableMatches = allMatches
        .where((m) => m.tournamentId != widget.id)
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('SELECCIONAR PARTIDO'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableMatches.length,
              itemBuilder: (context, index) {
                final match = availableMatches[index];
                return ListTile(
                  title: Text('PARTIDO contra ${match.opponentId}'),
                  subtitle: Text(match.dateTime.toString()),
                  onTap: () async {
                    final updatedMatch = entity.Match(
                      id: match.id,
                      tournamentId: widget.id!,
                      opponentId: match.opponentId,
                      dateTime: match.dateTime,
                      locationType: match.locationType,
                      matchday: match.matchday,
                      phase: match.phase,
                      homeScore: match.homeScore,
                      awayScore: match.awayScore,
                    );
                    final matchRepo = context.read<MatchRepository>();
                    final navigator = Navigator.of(context);
                    await matchRepo.saveMatch(updatedMatch);
                    if (mounted) {
                      navigator.pop();
                      _loadData();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _createNewMatch() async {
    // Navigate to match form with pre-filled tournament ID
    // We can use query parameters or state depending on how MatchFormPage is built
    context
        .push('/matches/new?tournamentId=${widget.id}')
        .then((_) => _loadData());
  }
}
