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

  const MatchLoaded({required this.match, required this.plays});

  @override
  List<Object?> get props => [match, plays];
}

class MatchError extends MatchState {
  final String message;
  const MatchError(this.message);

  @override
  List<Object?> get props => [message];
}
