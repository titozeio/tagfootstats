import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';

class TeamFormPage extends StatefulWidget {
  final bool isInitialSetup;
  final Team? team;

  const TeamFormPage({super.key, this.isInitialSetup = false, this.team});

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team?.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'SETUP YOUR TEAM' : 'EDIT TEAM'),
        actions: [
          if (!widget.isInitialSetup && widget.team != null && !_isSaving)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.accentRed),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'TEAM NAME',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    widget.isInitialSetup ? 'CREATE TEAM' : 'SAVE CHANGES',
                  ),
                ),
              if (!widget.isInitialSetup &&
                  widget.team != null &&
                  !_isSaving) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/players/${widget.team!.id}'),
                  icon: const Icon(Icons.person),
                  label: const Text('MANAGE PLAYERS'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DELETE TEAM?'),
        content: const Text(
          'Are you sure you want to delete this team? All associated players and stats might be affected.',
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
      setState(() => _isSaving = true);
      try {
        await context.read<TeamRepository>().deleteTeam(widget.team!.id);
        if (mounted) context.pop();
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final team = Team(
          id:
              widget.team?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          isOwnTeam: widget.isInitialSetup || (widget.team?.isOwnTeam ?? false),
        );

        await context
            .read<TeamRepository>()
            .saveTeam(team)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw Exception(
                'SAVE TIMEOUT. Check internet or Firebase rules.',
              ),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TEAM SAVED SUCCESSFULLY')),
          );
          context.read<AppBloc>().add(InitializeApp());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ERROR: ${e.toString()}')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
