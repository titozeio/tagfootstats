part of 'match_bloc.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatch extends MatchEvent {
  final String matchId;
  const LoadMatch(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class AddPlayEvent extends MatchEvent {
  final Play play;
  const AddPlayEvent(this.play);

  @override
  List<Object?> get props => [play];
}

class MatchUpdatedEvent extends MatchEvent {
  final Match? match;
  final List<Play> plays;
  const MatchUpdatedEvent(this.match, this.plays);

  @override
  List<Object?> get props => [match, plays];
}
