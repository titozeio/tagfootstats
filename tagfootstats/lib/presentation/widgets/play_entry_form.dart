import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/play.dart';

class PlayEntryForm extends StatefulWidget {
  final Function(PlayPhase phase, String action, String outcome, int points)
  onPlayAdded;

  const PlayEntryForm({super.key, required this.onPlayAdded});

  @override
  State<PlayEntryForm> createState() => _PlayEntryFormState();
}

class _PlayEntryFormState extends State<PlayEntryForm> {
  PlayPhase _selectedPhase = PlayPhase.ataque;
  String _selectedAction = 'Pase';
  final String _selectedOutcome = 'Completo';
  int _points = 0;

  final Map<PlayPhase, List<String>> _actionsByPhase = {
    PlayPhase.ataque: [
      'Pase',
      'Carrera',
      'Recepcion',
      'Sack',
      'Safety',
      'Fumble',
      'Falta',
    ],
    PlayPhase.defensa: ['Flag Pull', 'Intercepcion', 'Falta'],
    PlayPhase.extraPoint: ['Pase', 'Carrera'],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'RECORD PLAY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Phase Selection
          SegmentedButton<PlayPhase>(
            segments: const [
              ButtonSegment(value: PlayPhase.ataque, label: Text('ATAQUE')),
              ButtonSegment(value: PlayPhase.defensa, label: Text('DEFENSA')),
              ButtonSegment(value: PlayPhase.extraPoint, label: Text('EXTRA')),
            ],
            selected: {_selectedPhase},
            onSelectionChanged: (value) {
              setState(() {
                _selectedPhase = value.first;
                _selectedAction = _actionsByPhase[_selectedPhase]!.first;
              });
            },
          ),
          const SizedBox(height: 16),

          // Action Dropdown
          DropdownButtonFormField<String>(
            value: _selectedAction,
            decoration: const InputDecoration(labelText: 'ACTION'),
            items: _actionsByPhase[_selectedPhase]!
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (val) => setState(() => _selectedAction = val!),
          ),
          const SizedBox(height: 16),

          // Points selector (Simple counter)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'POINTS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(
                      () => _points = (_points > 0) ? _points - 1 : 0,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_points',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _points++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              widget.onPlayAdded(
                _selectedPhase,
                _selectedAction,
                _selectedOutcome,
                _points,
              );
              // reset points
              setState(() => _points = 0);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text(
              'SUBMIT PLAY',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
