import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/feedback_utils.dart';
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
    int minute,
    int? down,
    List<String> players,
  )
  onPlayAdded;
  final int homeScore;
  final int awayScore;
  final List<Play> recentPlays;

  const PlayEntryForm({
    super.key,
    required this.phase,
    this.players = const [],
    required this.onPlayAdded,
    this.homeScore = 0,
    this.awayScore = 0,
    this.recentPlays = const [],
  });

  @override
  State<PlayEntryForm> createState() => _PlayEntryFormState();
}

class _PlayEntryFormState extends State<PlayEntryForm> {
  String? _selectedPlayerId;
  String? _selectedAction;
  int _yards = 0;
  bool _isTouchdown = false;
  int _extraPointValue = 0; // 0, 1, 2
  int _minute = 0;
  int? _selectedDown;
  String? _selectedPassOutcome;
  String? _selectedPlayer2Id;

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
      _extraPointValue = 0;
      _minute = 0;
      _selectedDown = null;
      _selectedPassOutcome = null;
      _selectedPlayer2Id = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
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
            _buildMinuteSelector(),
            const SizedBox(height: 20),
            _buildDownSelector(),
            const SizedBox(height: 20),
            _buildActionGrid(),
            if (_selectedAction == 'PASE') ...[
              const SizedBox(height: 12),
              _buildPassOutcomeSelector(),
            ],
            const SizedBox(height: 20),
            _buildYardageSelector(),
            const SizedBox(height: 24),
            _buildOutcomeToggles(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 32),
            _buildRecentPlaysSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPlaysSection() {
    if (widget.recentPlays.isEmpty) return const SizedBox.shrink();

    final lastThree = widget.recentPlays.reversed.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVIDAD RECIENTE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white24,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...lastThree.map(
          (p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '${p.minute}\'',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.nflGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${p.action} - ${p.outcome}'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (p.points > 0)
                  Text(
                    '+${p.points}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
          'NUEVA JUGADA DE ${widget.phase.name.toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Text(
          '${widget.homeScore} - ${widget.awayScore}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.nflGold,
          ),
        ),
      ],
    );
  }

  Widget _buildDownSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OPORTUNIDAD (DOWN)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [1, 2, 3, 4].map((d) {
            final isSelected = _selectedDown == d;
            return InkWell(
              onTap: () => setState(() => _selectedDown = d),
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.nflGold : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.nflGold
                        : AppColors.glassBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dº',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPassOutcomeSelector() {
    final options = ['COMPLETO', 'INCOMPLETO', 'INTERCEPTADO'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((opt) {
        final isSelected = _selectedPassOutcome == opt;
        return InkWell(
          onTap: () => setState(() => _selectedPassOutcome = opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.nflGold : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.nflGold : AppColors.glassBorder,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMinuteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MINUTO DE LA JUGADA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              'MIN: $_minute',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.nflGold,
              ),
            ),
          ],
        ),
        Slider(
          value: _minute.toDouble(),
          min: 0,
          max: 60,
          divisions: 60,
          activeColor: AppColors.nflGold,
          inactiveColor: Colors.white10,
          label: _minute.toString(),
          onChanged: (val) => setState(() => _minute = val.toInt()),
        ),
      ],
    );
  }

  Widget _buildPlayerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'JUGADORES INVOLUCRADOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPlayerId,
                decoration: _inputDecoration(
                  _selectedAction == 'PASE' ? 'QB' : 'JUGADOR',
                ),
                items: _playerItems(),
                onChanged: (val) => setState(() => _selectedPlayerId = val),
              ),
            ),
            if (_selectedAction == 'PASE') ...[
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPlayer2Id,
                  decoration: _inputDecoration('RECEPTOR'),
                  items: _playerItems(),
                  onChanged: (val) => setState(() => _selectedPlayer2Id = val),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
      filled: true,
      fillColor: Colors.black12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  List<DropdownMenuItem<String>> _playerItems() {
    return widget.players
        .map(
          (p) => DropdownMenuItem(
            value: p.id,
            child: Text('#${p.dorsal} ${p.firstName}'),
          ),
        )
        .toList();
  }

  Widget _buildActionGrid() {
    final actions = widget.phase == PlayPhase.ataque
        ? ['PASE', 'CARRERA', 'SACK', 'FUMBLE']
        : ['FLAG QUITADO', 'SACK', 'INTERCEPCIÓN', 'BATTED', 'SAFETY'];

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
              'YARDAS Ganadas / Perdidas',
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
              if (_isTouchdown) _extraPointValue = 0;
            }),
            Icons.star,
          ),
        ),
        const SizedBox(width: 12),
        _buildExtraPointSelector(),
      ],
    );
  }

  Widget _buildExtraPointSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [0, 1, 2].map((v) {
          final isSelected = _extraPointValue == v;
          return InkWell(
            onTap: () => setState(() {
              _extraPointValue = v;
              if (v > 0) _isTouchdown = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.nflGold : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                v == 0 ? 'NO PAT' : '${v}PT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
              ? AppColors.nflGold.withValues(alpha: 0.2)
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
              if (_extraPointValue > 0) {
                points = _extraPointValue;
                outcome = 'PAT ${_extraPointValue}PT';
              }
              if (_selectedAction == 'SAFETY') {
                points = 2;
                outcome = 'SAFETY';
              }
              if (_selectedAction == 'PASE' && _selectedPassOutcome != null) {
                outcome = 'PASE $_selectedPassOutcome';
              }

              final playerIds = <String>[];
              if (_selectedPlayerId != null) {
                playerIds.add(_selectedPlayerId!);
              }
              if (_selectedPlayer2Id != null) {
                playerIds.add(_selectedPlayer2Id!);
              }

              widget.onPlayAdded(
                _selectedAction!,
                outcome,
                points,
                _yards,
                _minute,
                _selectedDown,
                playerIds,
              );
              final playDescription = points > 0
                  ? '$outcome (+ $points PTS)'
                  : outcome;
              FeedbackUtils.showSuccess(
                context,
                'JUGADA REGISTRADA: $playDescription',
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
        'REGISTRAR JUGADA',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
    );
  }
}
