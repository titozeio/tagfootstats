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
  late TextEditingController _shortNameController;
  late TextEditingController _logoUrlController;
  bool _isOwnTeam = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team?.name ?? '');
    _shortNameController = TextEditingController(
      text: widget.team?.shortName ?? '',
    );
    _logoUrlController = TextEditingController(
      text: widget.team?.logoUrl ?? '',
    );
    _isOwnTeam = widget.team?.isOwnTeam ?? widget.isInitialSetup;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isInitialSetup ? 'CONFIGURA TU EQUIPO' : 'EDITAR EQUIPO',
        ),
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
                  labelText: 'NOMBRE DEL EQUIPO',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shortNameController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'NOMBRE CORTO (EJ: SHK)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logoUrlController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'URL DEL ESCUDO (BADGE)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('EQUIPO DEL USUARIO'),
                subtitle: const Text(
                  'Solo un equipo puede ser marcado como principal',
                ),
                value: _isOwnTeam,
                activeThumbColor: AppColors.nflGold,
                onChanged: _isSaving
                    ? null
                    : (val) => setState(() => _isOwnTeam = val),
              ),
              const SizedBox(height: 24),
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    widget.isInitialSetup ? 'CREAR EQUIPO' : 'GUARDAR CAMBIOS',
                  ),
                ),
              if (!widget.isInitialSetup &&
                  widget.team != null &&
                  !_isSaving) ...[
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/players/${widget.team!.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.nflGold,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.people),
                  label: const Text('GESTIONAR JUGADORES (ROSTER)'),
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
        title: const Text('¿ELIMINAR EQUIPO?'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este equipo? Todos los jugadores y estadísticas asociados podrían verse afectados.',
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
          shortName: _shortNameController.text.toUpperCase(),
          logoUrl: _logoUrlController.text,
          isOwnTeam: _isOwnTeam,
        );

        if (_isOwnTeam) {
          // Ensure atomicity if marking as own team
          await context.read<TeamRepository>().setAsOwnTeam(team.id);
          // Now save the other fields (though setAsOwnTeam only sets the flag)
          // We still need to save everything else
        }

        await context
            .read<TeamRepository>()
            .saveTeam(team)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw Exception('TIEMPO DE ESPERA AGOTADO.'),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('EQUIPO GUARDADO CON ÉXITO')),
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
