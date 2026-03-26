import 'package:equatable/equatable.dart';

enum LocationType { local, visitante, neutro }

class Match extends Equatable {
  final String id;
  final String tournamentId;
  final String opponentId;
  final DateTime dateTime;
  final LocationType locationType;
  final int? matchday; // For league
  final String? phase; // For cup
  final int homeScore;
  final int awayScore;

  const Match({
    required this.id,
    required this.tournamentId,
    required this.opponentId,
    required this.dateTime,
    required this.locationType,
    this.matchday,
    this.phase,
    this.homeScore = 0,
    this.awayScore = 0,
  });

  @override
  List<Object?> get props => [
    id,
    tournamentId,
    opponentId,
    dateTime,
    locationType,
    matchday,
    phase,
    homeScore,
    awayScore,
  ];
}
