import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/player.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';

class PlayerFormPage extends StatefulWidget {
  final String? id;
  final String? teamId;

  const PlayerFormPage({super.key, this.id, this.teamId});

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dorsalController;
  late TextEditingController _photoUrlController;
  PlayerPosition _selectedPosition = PlayerPosition.both;
  bool _isLoading = true;
  String? _currentTeamId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dorsalController = TextEditingController();
    _photoUrlController = TextEditingController();
    _currentTeamId = widget.teamId;
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.id != null) {
      final player = await context.read<PlayerRepository>().getPlayerById(
        widget.id!,
      );
      if (player != null) {
        setState(() {
          _firstNameController.text = player.firstName;
          _lastNameController.text = player.lastName;
          _dorsalController.text = player.dorsal.toString();
          _photoUrlController.text = player.photoUrl ?? '';
          _selectedPosition = player.position;
          _currentTeamId = player.teamId;
        });
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
        title: Text(widget.id == null ? 'NUEVO JUGADOR' : 'EDITAR JUGADOR'),
        actions: [
          if (widget.id != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.accentRed),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'NOMBRE',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'APELLIDO',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dorsalController,
                decoration: const InputDecoration(
                  labelText: 'DORSAL (#)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PlayerPosition>(
                initialValue: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'POSICIÓN PRINCIPAL',
                  border: OutlineInputBorder(),
                ),
                items: PlayerPosition.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedPosition = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL DE LA FOTO (OPCIONAL)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _photoUrlController,
                builder: (context, value, _) {
                  final url = value.text.trim();
                  return Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white12,
                          child: ClipOval(
                            child: url.isNotEmpty
                                ? Image.network(
                                    url,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                  )
                                : const Icon(Icons.add_a_photo, size: 40),
                          ),
                        ),
                        if (url.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'VISTA PREVIA',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  widget.id == null ? 'CREAR JUGADOR' : 'GUARDAR CAMBIOS',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final player = Player(
        id: widget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        teamId: _currentTeamId!,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dorsal: int.parse(_dorsalController.text),
        position: _selectedPosition,
        photoUrl: _photoUrlController.text,
      );

      await context.read<PlayerRepository>().savePlayer(player);
      if (mounted) {
        context.pushReplacement('/players/$_currentTeamId');
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿ELIMINAR JUGADOR?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final teamId = _currentTeamId;
      await context.read<PlayerRepository>().deletePlayer(widget.id!);
      if (mounted) {
        if (teamId != null) {
          context.pushReplacement('/players/$teamId');
        } else {
          context.pop();
        }
      }
    }
  }
}
