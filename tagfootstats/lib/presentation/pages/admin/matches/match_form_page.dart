import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/entities/tournament.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';

import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/entities/team.dart';

class MatchFormPage extends StatefulWidget {
  final entity.Match? match;
  final String? tournamentId;

  const MatchFormPage({super.key, this.match, this.tournamentId});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _opponentController;
  late TextEditingController _matchdayController;
  late TextEditingController _phaseController;

  String? _selectedTournamentId;
  entity.LocationType _locationType = entity.LocationType.local;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isSaving = false;
  List<Team> _allTeams = [];
  List<Tournament> _allTournaments = [];
  Tournament? _selectedTournament;
  bool _isAddingNewTeam = false;
  String _selectedPhase = 'Final';
  bool _isCustomPhase = false;

  @override
  void initState() {
    super.initState();
    _opponentController = TextEditingController(text: widget.match?.opponentId);
    _matchdayController = TextEditingController(
      text: widget.match?.matchday?.toString(),
    );
    _phaseController = TextEditingController(text: widget.match?.phase);

    if (widget.match != null) {
      _selectedTournamentId = widget.match!.tournamentId;
      _locationType = widget.match!.locationType;
      _selectedDate = widget.match!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.match!.dateTime);
    } else if (widget.tournamentId != null) {
      _selectedTournamentId = widget.tournamentId;
    }
    _phaseController.text = _selectedPhase;

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final teamRepo = context.read<TeamRepository>();
      final tournamentRepo = context.read<TournamentRepository>();

      final teams = await teamRepo.getTeams();
      final tournaments = await tournamentRepo.getTournaments();

      if (mounted) {
        setState(() {
          _allTeams = teams;
          _allTournaments = tournaments;

          if (_selectedTournamentId == null && tournaments.isNotEmpty) {
            // Find an "open" tournament (not ended) or the latest one
            final now = DateTime.now();
            final active = tournaments.where((t) => t.endDate.isAfter(now));
            if (active.isNotEmpty) {
              _selectedTournamentId = active.first.id;
              _selectedTournament = active.first;
            } else {
              _selectedTournamentId = tournaments.first.id;
              _selectedTournament = tournaments.first;
            }
          } else if (_selectedTournamentId != null) {
            _selectedTournament = tournaments.firstWhere(
              (t) => t.id == _selectedTournamentId,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _matchdayController.dispose();
    _phaseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final teamRepo = context.read<TeamRepository>();
    final matchRepo = context.read<MatchRepository>();
    final router = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_selectedTournamentId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un torneo')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      String opponentName = _opponentController.text.trim();

      if (_isAddingNewTeam && opponentName.isNotEmpty) {
        final newTeamId = DateTime.now().millisecondsSinceEpoch.toString();
        final newTeam = Team(
          id: newTeamId,
          name: opponentName,
          logoUrl: '',
          isOwnTeam: false,
        );
        await teamRepo.saveTeam(newTeam);
      }

      final match = entity.Match(
        id:
            widget.match?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        tournamentId: _selectedTournamentId!,
        opponentId: opponentName,
        dateTime: finalDateTime,
        locationType: _locationType,
        matchday: (_selectedTournament?.type == TournamentType.liga)
            ? int.tryParse(_matchdayController.text)
            : null,
        phase: (_selectedTournament?.type == TournamentType.copa)
            ? (_isCustomPhase ? _phaseController.text : _selectedPhase)
            : null,
        homeScore: widget.match?.homeScore ?? 0,
        awayScore: widget.match?.awayScore ?? 0,
      );

      await matchRepo.saveMatch(match).timeout(const Duration(seconds: 10));

      if (mounted) {
        router.pushReplacement('/match/${match.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al guardar el partido: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match == null ? 'NUEVO PARTIDO' : 'EDITAR PARTIDO'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTournamentDropdown(),
              const SizedBox(height: 20),
              _buildOpponentSelector(),
              const SizedBox(height: 20),
              _buildLocationTypeSelector(),
              const SizedBox(height: 20),
              _buildDateTimePicker(context),
              const SizedBox(height: 20),
              _buildJornadaOrFase(),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.nflGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'EMPEZAR GRABACIÓN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpponentSelector() {
    final teams = _allTeams.where((t) => !t.isOwnTeam).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _isAddingNewTeam
              ? 'NEW'
              : (_opponentController.text.isEmpty
                    ? null
                    : _opponentController.text),
          decoration: const InputDecoration(
            labelText: 'EQUIPO OPONENTE',
            prefixIcon: Icon(Icons.shield),
          ),
          items: [
            ...teams.map(
              (t) => DropdownMenuItem(value: t.name, child: Text(t.name)),
            ),
            const DropdownMenuItem(
              value: 'NEW',
              child: Text(
                '+ Añadir nuevo equipo',
                style: TextStyle(color: AppColors.nflGold),
              ),
            ),
          ],
          onChanged: (val) {
            setState(() {
              if (val == 'NEW') {
                _isAddingNewTeam = true;
                _opponentController.clear();
              } else {
                _isAddingNewTeam = false;
                _opponentController.text = val ?? '';
              }
            });
          },
          validator: (v) =>
              (v == null && !_isAddingNewTeam) ? 'Requerido' : null,
        ),
        if (_isAddingNewTeam) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _opponentController,
            decoration: const InputDecoration(
              labelText: 'NOMBRE DEL NUEVO EQUIPO',
              hintText: 'Ej: Sharks Torrejón',
            ),
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
            autofocus: true,
          ),
        ],
      ],
    );
  }

  Widget _buildJornadaOrFase() {
    if (_selectedTournament == null) return const SizedBox.shrink();

    if (_selectedTournament!.type == TournamentType.liga) {
      return Row(
        children: [
          const Text(
            'JORNADA: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: int.tryParse(_matchdayController.text) ?? 1,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: List.generate(
                30,
                (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
              ),
              onChanged: (val) =>
                  setState(() => _matchdayController.text = val.toString()),
            ),
          ),
        ],
      );
    } else {
      final phases = [
        'Final',
        'Semifinal',
        'Cuartos',
        'Octavos',
        'Liguilla',
        'Otros',
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FASE DEL TORNEO: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _isCustomPhase ? 'Otros' : _selectedPhase,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: phases
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) {
              setState(() {
                if (val == 'Otros') {
                  _isCustomPhase = true;
                } else {
                  _isCustomPhase = false;
                  _selectedPhase = val!;
                  _phaseController.text = val;
                }
              });
            },
          ),
          if (_isCustomPhase) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _phaseController,
              decoration: const InputDecoration(
                labelText: 'ESPECIFICA LA FASE',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
          ],
        ],
      );
    }
  }

  Widget _buildTournamentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedTournamentId,
      decoration: const InputDecoration(
        labelText: 'TORNEO',
        prefixIcon: Icon(Icons.emoji_events),
      ),
      items: _allTournaments
          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedTournamentId = val;
          _selectedTournament = _allTournaments.firstWhere((t) => t.id == val);
        });
      },
      hint: const Text('Seleccionar Torneo'),
      validator: (v) => v == null ? 'Requerido' : null,
    );
  }

  Widget _buildLocationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UBICACIÓN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<entity.LocationType>(
          segments: const [
            ButtonSegment(
              value: entity.LocationType.local,
              label: Text('LOCAL'),
            ),
            ButtonSegment(
              value: entity.LocationType.visitante,
              label: Text('VISITANTE'),
            ),
            ButtonSegment(
              value: entity.LocationType.neutro,
              label: Text('NEUTRO'),
            ),
          ],
          selected: {_locationType},
          onSelectionChanged: (v) => setState(() => _locationType = v.first),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: AppColors.nflGold,
            ),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: AppColors.nflGold,
            ),
            icon: const Icon(Icons.access_time),
            label: Text(_selectedTime.format(context)),
          ),
        ),
      ],
    );
  }
}
