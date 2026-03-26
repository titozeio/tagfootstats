import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/tournament.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
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
      final tournament = await context
          .read<TournamentRepository>()
          .getTournamentById(widget.id!);
      if (tournament != null) {
        setState(() {
          _nameController.text = tournament.name;
          _startDate = tournament.startDate;
          _endDate = tournament.endDate;
          _type = tournament.type;
          _teamIds = List.from(tournament.teamIds);
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
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'NEW TOURNAMENT' : 'EDIT TOURNAMENT'),
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
                  labelText: 'TOURNAMENT NAME',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<TournamentType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'TYPE',
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
                'START DATE',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                'END DATE',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
              const SizedBox(height: 32),
              const Text(
                'TEAMS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._teamIds.map((id) => _buildTeamTile(id)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _showAddTeamDialog,
                icon: const Icon(Icons.group_add),
                label: const Text('ADD EXISTING TEAM'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quickTeamController,
                      decoration: const InputDecoration(
                        labelText: 'NEW QUICK TEAM NAME',
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.id == null ? 'CREATE TOURNAMENT' : 'SAVE CHANGES',
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
        final name = snapshot.data?.name ?? 'Loading...';
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
    final team = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _quickTeamController.text,
    );
    await context.read<TeamRepository>().saveTeam(team);
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
          title: const Text('SELECT TEAM'),
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

      await context.read<TournamentRepository>().saveTournament(tournament);
      if (mounted) context.pop();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DELETE TOURNAMENT?'),
        content: const Text(
          'THIS ACTION IS IRREVERSIBLE. ALL MATCHES AND STATS ASSOCIATED WITH THIS TOURNAMENT WILL BE LOST.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TournamentRepository>().deleteTournament(widget.id!);
      if (mounted) context.pop();
    }
  }
}
