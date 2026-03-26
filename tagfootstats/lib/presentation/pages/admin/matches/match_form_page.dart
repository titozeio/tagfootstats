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

  const MatchFormPage({super.key, this.match});

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
    }

    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await context.read<TeamRepository>().getTeams();
      if (mounted) setState(() => _allTeams = teams);
    } catch (e) {
      debugPrint('Error loading teams: $e');
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
    if (_selectedTournamentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tournament')),
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

      final opponentName = _opponentController.text.trim();

      // 1. Resolve Opponent ID (search existing or create new)
      final existingTeam = _allTeams.firstWhere(
        (t) => t.name.toLowerCase() == opponentName.toLowerCase(),
        orElse: () => Team(id: '', name: opponentName),
      );

      if (existingTeam.id.isEmpty) {
        // Create new team entry for the opponent
        final newTeamId = DateTime.now().millisecondsSinceEpoch.toString();
        final newTeam = Team(
          id: newTeamId,
          name: opponentName,
          logoUrl: '',
          isOwnTeam: false,
        );
        await context
            .read<TeamRepository>()
            .saveTeam(newTeam)
            .timeout(const Duration(seconds: 10));
      }

      final match = entity.Match(
        id:
            widget.match?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        tournamentId: _selectedTournamentId!,
        opponentId: opponentName,
        dateTime: finalDateTime,
        locationType: _locationType,
        matchday: int.tryParse(_matchdayController.text),
        phase: _phaseController.text.isNotEmpty ? _phaseController.text : null,
        homeScore: widget.match?.homeScore ?? 0,
        awayScore: widget.match?.awayScore ?? 0,
      );

      await context
          .read<MatchRepository>()
          .saveMatch(match)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        context.pushReplacement('/match/${match.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving match: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match == null ? 'NEW MATCH' : 'EDIT MATCH'),
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
              _buildOpponentAutocomplete(),
              const SizedBox(height: 20),
              _buildLocationTypeSelector(),
              const SizedBox(height: 20),
              _buildDateTimePicker(context),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _matchdayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MATCHDAY #',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phaseController,
                      decoration: const InputDecoration(
                        labelText: 'PHASE (e.g. Final)',
                      ),
                    ),
                  ),
                ],
              ),
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
                        'START RECORDING',
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

  Widget _buildOpponentAutocomplete() {
    return Autocomplete<Team>(
      displayStringForOption: (Team option) => option.name,
      initialValue: TextEditingValue(text: _opponentController.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<Team>.empty();
        }
        return _allTeams.where((Team option) {
          return option.name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (Team selection) {
        _opponentController.text = selection.name;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Sync our controller with the autocomplete controller
        controller.addListener(() {
          _opponentController.text = controller.text;
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'OPPONENT NAME',
            prefixIcon: Icon(Icons.shield),
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        );
      },
    );
  }

  Widget _buildTournamentDropdown() {
    return FutureBuilder<List<Tournament>>(
      future: context.read<TournamentRepository>().getTournaments(),
      builder: (context, snapshot) {
        final tournaments = snapshot.data ?? [];
        return DropdownButtonFormField<String>(
          value: _selectedTournamentId,
          decoration: const InputDecoration(
            labelText: 'TOURNAMENT',
            prefixIcon: Icon(Icons.emoji_events),
          ),
          items: tournaments
              .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
              .toList(),
          onChanged: (val) => setState(() => _selectedTournamentId = val),
          hint: const Text('Select Tournament'),
          validator: (v) => v == null ? 'Required' : null,
        );
      },
    );
  }

  Widget _buildLocationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOCATION',
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
          child: OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            icon: const Icon(Icons.access_time),
            label: Text(_selectedTime.format(context)),
          ),
        ),
      ],
    );
  }
}
