import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/play.dart';
import '../../domain/entities/player.dart';

class PlayEntryForm extends StatefulWidget {
  final PlayPhase phase;
  final List<Player> players;
  final Function(
    String action,
    String outcome,
    int points,
    int yardas,
    List<String> players,
  )
  onPlayAdded;

  const PlayEntryForm({
    super.key,
    required this.phase,
    this.players = const [],
    required this.onPlayAdded,
  });

  @override
  State<PlayEntryForm> createState() => _PlayEntryFormState();
}

class _PlayEntryFormState extends State<PlayEntryForm> {
  String? _selectedPlayerId;
  String? _selectedAction;
  int _yards = 0;
  bool _isTouchdown = false;
  bool _isExtraPoint = false;

  @override
  void didUpdateWidget(PlayEntryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _selectedPlayerId = null;
      _selectedAction = null;
      _yards = 0;
      _isTouchdown = false;
      _isExtraPoint = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPlayerSelection(),
            const SizedBox(height: 20),
            _buildActionGrid(),
            const SizedBox(height: 20),
            _buildYardageSelector(),
            const SizedBox(height: 24),
            _buildOutcomeToggles(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final color = widget.phase == PlayPhase.ataque
        ? AppColors.primaryBlue
        : AppColors.accentRed;
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'NEW ${widget.phase.name.toUpperCase()} PLAY',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INVOLVED PLAYER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPlayerId,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black12,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person, color: AppColors.nflGold),
          ),
          items: widget.players
              .map(
                (p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('#${p.dorsal} ${p.firstName} ${p.lastName}'),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedPlayerId = val),
          hint: const Text('Select a player'),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    final actions = widget.phase == PlayPhase.ataque
        ? ['PASE', 'CARRERA', 'SACK', 'FUMBLE']
        : ['FLAG PULLED', 'SACK', 'INTERCEPT', 'BLITZER'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) {
        final isSelected = _selectedAction == action;
        return InkWell(
          onTap: () => setState(() => _selectedAction = action),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.nflGold : Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.nflGold : AppColors.glassBorder,
              ),
            ),
            child: Text(
              action,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYardageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'YARDS Gained / Lost',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              '$_yards YDS',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.nflGold,
              ),
            ),
          ],
        ),
        Slider(
          value: _yards.toDouble(),
          min: -20,
          max: 60,
          activeColor: AppColors.nflGold,
          inactiveColor: Colors.white10,
          onChanged: (val) => setState(() => _yards = val.toInt()),
        ),
      ],
    );
  }

  Widget _buildOutcomeToggles() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            'TOUCHDOWN',
            _isTouchdown,
            () => setState(() {
              _isTouchdown = !_isTouchdown;
              if (_isTouchdown) _isExtraPoint = false;
            }),
            Icons.star,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            'EXTRA PT',
            _isExtraPoint,
            () => setState(() {
              _isExtraPoint = !_isExtraPoint;
              if (_isExtraPoint) _isTouchdown = false;
            }),
            Icons.add_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String label,
    bool active,
    VoidCallback onTap,
    IconData icon,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.nflGold.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.nflGold : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppColors.nflGold : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.nflGold : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedAction != null;
    return ElevatedButton(
      onPressed: canSubmit
          ? () {
              int points = 0;
              String outcome = 'Success';
              if (_isTouchdown) {
                points = 6;
                outcome = 'TOUCHDOWN';
              }
              if (_isExtraPoint) {
                points = 1; // Default
                outcome = 'EXTRA POINT';
              }

              widget.onPlayAdded(
                _selectedAction!,
                outcome,
                points,
                _yards,
                _selectedPlayerId != null ? [_selectedPlayerId!] : [],
              );
              _resetForm();
            }
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: widget.phase == PlayPhase.ataque
            ? AppColors.primaryBlue
            : AppColors.accentRed,
        disabledBackgroundColor: Colors.white10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'SUBMIT PLAY',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
    );
  }
}
