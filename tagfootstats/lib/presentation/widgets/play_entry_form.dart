import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/feedback_utils.dart';
import '../../domain/entities/play.dart';
import '../../domain/entities/player.dart';

/// Form for recording a single play during a match.
///
/// All plays are registered from the user's team perspective:
/// - [PlayPhase.ataque]: user team executes an offensive play (points → user team).
/// - [PlayPhase.defensa]: user team executes a defensive play. A touchdown
///   checked here means the **rival** scored (scoringTeamId = opponentTeamId).
class PlayEntryForm extends StatefulWidget {
  final PlayPhase phase;
  final List<Player> players;
  final String opponentTeamId;
  final Function(
    String action,
    String outcome,
    int points,
    int yardas,
    int minute,
    int? down,
    List<String> players,
    List<String> opponentPlayers,
    String? scoringTeamId,
    String? foulType,
    bool isLossOfDown,
    bool isAutomaticFirstDown,
    String? penalizingTeamId,
  )
  onPlayAdded;
  final int homeScore;
  final int awayScore;
  final List<Play> recentPlays;

  const PlayEntryForm({
    super.key,
    required this.phase,
    this.players = const [],
    required this.opponentTeamId,
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
  bool _isOt = false;
  int? _selectedDown;
  String? _selectedPassOutcome;
  String? _selectedPlayer2Id;
  String? _foulType;
  bool _isLossOfDown = false;
  bool _isAutomaticFirstDown = false;
  String? _penalizingTeamId;

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
      _isOt = false;
      _selectedDown = null;
      _selectedPassOutcome = null;
      _selectedPlayer2Id = null;
      _foulType = null;
      _isLossOfDown = false;
      _isAutomaticFirstDown = false;
      _penalizingTeamId = null;
    });
  }

  /// Computes the actual minute to store for this play.
  /// OT plays are stored as 61, 62, 63... based on how many OT plays exist.
  int _resolveMinute() {
    if (!_isOt) return _minute;
    final otCount = widget.recentPlays.where((p) => p.minute >= 61).length;
    return 61 + otCount;
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
            if (_selectedAction == 'FALTA') ...[
              const SizedBox(height: 20),
              _buildFoulDetails(),
            ],
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
                  p.minute >= 61 ? 'OT' : '${p.minute}\'',
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
        ? AppColors.offensivePurple
        : AppColors.defensiveGreen;
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
            // OT toggle
            GestureDetector(
              onTap: () => setState(() {
                _isOt = !_isOt;
                if (_isOt) _minute = 0; // reset slider cuando se activa OT
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isOt ? AppColors.nflGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isOt ? AppColors.nflGold : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  'OT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _isOt ? Colors.black : Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Text(
              _isOt ? 'OT' : 'MIN: $_minute',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.nflGold,
              ),
            ),
          ],
        ),
        if (!_isOt)
          Slider(
            value: _minute.toDouble(),
            min: 0,
            max: 60,
            divisions: 60,
            activeColor: AppColors.nflGold,
            inactiveColor: Colors.white10,
            label: _minute.toString(),
            onChanged: (val) => setState(() => _minute = val.toInt()),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Jugada en Tiempo Extra (OT)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
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
          'JUGADORES INVOLUCRADOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedPlayerId,
          decoration: _inputDecoration(
            _selectedAction == 'PASE' ? 'QB' : 'JUGADOR',
          ),
          items: _playerItems(widget.players),
          onChanged: (val) => setState(() => _selectedPlayerId = val),
        ),
        if (_selectedAction == 'PASE') ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedPlayer2Id,
            decoration: _inputDecoration('RECEPTOR / 2º JUGADOR'),
            items: _playerItems(widget.players),
            onChanged: (val) => setState(() => _selectedPlayer2Id = val),
          ),
        ],
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

  List<DropdownMenuItem<String>> _playerItems(List<Player> players) {
    return players
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
        ? ['PASE', 'CARRERA', 'SACK', 'FUMBLE', 'FALTA']
        : [
            'FLAG QUITADO',
            'AVANCE MÁXIMO',
            'FLAG FALLIDO',
            'SACK',
            'INTERCEPCIÓN',
            'BATTED',
            'SAFETY',
            'FALTA',
          ];

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
    final isDefense = widget.phase == PlayPhase.defensa;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                isDefense ? 'TOUCHDOWN RIVAL' : 'TOUCHDOWN',
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
        ),
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

  Widget _buildFoulDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETALLES DE LA FALTA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _foulType,
          decoration: _inputDecoration('TIPO DE FALTA'),
          items: [
            'OFFSIDE / ENCROACHMENT',
            'PASS INTERFERENCE',
            'ILLEGAL CONTACT',
            'HOLDING',
            'ROUGHING THE PASSER',
            'FALSE START',
            'ILLEGAL MOTION',
            'FLAG GUARDING',
            'CHARGING',
            'BLOCKING',
            'OTRA',
          ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (val) => setState(() => _foulType = val),
        ),
        const SizedBox(height: 12),
        const Text(
          'EQUIPO PENALIZADO',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSmallTabButton(
              'PROPIO',
              _penalizingTeamId == 'OWN',
              () => setState(() => _penalizingTeamId = 'OWN'),
            ),
            const SizedBox(width: 8),
            _buildSmallTabButton(
              'RIVAL',
              _penalizingTeamId == 'OPPONENT',
              () => setState(() => _penalizingTeamId = 'OPPONENT'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                'LOD (Loss of Down)',
                _isLossOfDown,
                () => setState(() => _isLossOfDown = !_isLossOfDown),
                Icons.warning_amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleButton(
                '1st DOWN AUTO',
                _isAutomaticFirstDown,
                () => setState(
                  () => _isAutomaticFirstDown = !_isAutomaticFirstDown,
                ),
                Icons.forward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallTabButton(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.nflGold : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.nflGold : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.grey,
          ),
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
              String? scoringTeamId;

              if (_isTouchdown) {
                points = 6;
                if (widget.phase == PlayPhase.defensa) {
                  // TD in defense = the rival scored
                  outcome = 'TD RIVAL';
                  scoringTeamId = widget.opponentTeamId;
                } else {
                  outcome = 'TOUCHDOWN';
                  scoringTeamId = null; // own team by default
                }
              }
              if (_extraPointValue > 0) {
                points = _extraPointValue;
                outcome = 'PAT ${_extraPointValue}PT';
              }
              if (_selectedAction == 'SAFETY') {
                points = 2;
                outcome = 'SAFETY';
                scoringTeamId = null; // our team scored
              }
              if (_selectedAction == 'PASE' && _selectedPassOutcome != null) {
                outcome = 'PASE $_selectedPassOutcome';
              }
              if (_selectedAction == 'FALTA' && _foulType != null) {
                outcome = 'FALTA: $_foulType';
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
                _resolveMinute(),
                _selectedDown,
                playerIds,
                const [], // no more rival player IDs under new model
                scoringTeamId,
                _foulType,
                _isLossOfDown,
                _isAutomaticFirstDown,
                _penalizingTeamId,
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
            ? AppColors.offensivePurple
            : AppColors.defensiveGreen,
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
