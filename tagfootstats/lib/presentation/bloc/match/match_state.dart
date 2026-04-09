part of 'match_bloc.dart';

abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object?> get props => [];
}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchLoaded extends MatchState {
  final Match match;
  final List<Play> plays;
  final List<Player> players;
  final List<Player> opponentPlayers;
  final String opponentTeamName;

  const MatchLoaded({
    required this.match,
    required this.plays,
    this.players = const [],
    this.opponentPlayers = const [],
    required this.opponentTeamName,
  });

  @override
  List<Object?> get props => [
    match,
    plays,
    players,
    opponentPlayers,
    opponentTeamName,
  ];
}

class MatchError extends MatchState {
  final String message;
  const MatchError(this.message);

  @override
  List<Object?> get props => [message];
}
