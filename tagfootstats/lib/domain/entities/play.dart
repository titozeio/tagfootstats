import 'package:equatable/equatable.dart';

enum PlayPhase { ataque, defensa, extraPoint }

class Play extends Equatable {
  final String id;
  final String matchId;
  final PlayPhase phase;
  final int minute;
  final String action;
  final String outcome;
  final int points;
  final int yardas;
  final int? down;
  final List<String> involvedPlayerIds; // User's team players
  final List<String> opponentInvolvedPlayerIds; // Opponent's team players
  final String? scoringTeamId; // ID of the team that scored points (if any)
  final String? foulType;
  final bool isLossOfDown;
  final bool isAutomaticFirstDown;
  final String? penalizingTeamId;
  final String? penalizedPlayerId;

  const Play({
    required this.id,
    required this.matchId,
    required this.phase,
    required this.minute,
    required this.action,
    required this.outcome,
    this.points = 0,
    this.yardas = 0,
    this.down,
    this.involvedPlayerIds = const [],
    this.opponentInvolvedPlayerIds = const [],
    this.scoringTeamId,
    this.foulType,
    this.isLossOfDown = false,
    this.isAutomaticFirstDown = false,
    this.penalizingTeamId,
    this.penalizedPlayerId,
  });

  Play copyWith({
    String? id,
    String? matchId,
    PlayPhase? phase,
    int? minute,
    String? action,
    String? outcome,
    int? points,
    int? yardas,
    int? down,
    List<String>? involvedPlayerIds,
    List<String>? opponentInvolvedPlayerIds,
    String? scoringTeamId,
    String? foulType,
    bool? isLossOfDown,
    bool? isAutomaticFirstDown,
    String? penalizingTeamId,
    String? penalizedPlayerId,
  }) {
    return Play(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      phase: phase ?? this.phase,
      minute: minute ?? this.minute,
      action: action ?? this.action,
      outcome: outcome ?? this.outcome,
      points: points ?? this.points,
      yardas: yardas ?? this.yardas,
      down: down ?? this.down,
      involvedPlayerIds: involvedPlayerIds ?? this.involvedPlayerIds,
      opponentInvolvedPlayerIds:
          opponentInvolvedPlayerIds ?? this.opponentInvolvedPlayerIds,
      scoringTeamId: scoringTeamId ?? this.scoringTeamId,
      foulType: foulType ?? this.foulType,
      isLossOfDown: isLossOfDown ?? this.isLossOfDown,
      isAutomaticFirstDown: isAutomaticFirstDown ?? this.isAutomaticFirstDown,
      penalizingTeamId: penalizingTeamId ?? this.penalizingTeamId,
      penalizedPlayerId: penalizedPlayerId ?? this.penalizedPlayerId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    matchId,
    phase,
    minute,
    action,
    outcome,
    points,
    yardas,
    down,
    involvedPlayerIds,
    opponentInvolvedPlayerIds,
    scoringTeamId,
    foulType,
    isLossOfDown,
    isAutomaticFirstDown,
    penalizingTeamId,
    penalizedPlayerId,
  ];
}
