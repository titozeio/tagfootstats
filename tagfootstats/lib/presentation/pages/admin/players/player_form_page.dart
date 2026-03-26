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
  bool _isLoading = true;
  String? _currentTeamId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dorsalController = TextEditingController();
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
          _currentTeamId = player.teamId;
        });
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
        title: Text(widget.id == null ? 'NEW PLAYER' : 'EDIT PLAYER'),
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
                  labelText: 'FIRST NAME',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'LAST NAME',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dorsalController,
                decoration: const InputDecoration(
                  labelText: 'DORSAL (#)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  widget.id == null ? 'CREATE PLAYER' : 'SAVE CHANGES',
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
      );

      await context.read<PlayerRepository>().savePlayer(player);
      if (mounted) context.pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('DELETE PLAYER?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<PlayerRepository>().deletePlayer(widget.id!);
      if (mounted) context.pop();
    }
  }
}
