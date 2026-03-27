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
  final List<String> involvedPlayerIds;

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
  });

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
  ];
}
