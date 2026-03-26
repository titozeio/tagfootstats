import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/match.dart';
import '../../../domain/entities/play.dart';
import '../../../domain/repositories/match_repository.dart';
import '../../../domain/repositories/play_repository.dart';
import '../../../domain/usecases/add_play_to_match.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRepository matchRepository;
  final PlayRepository playRepository;
  final AddPlayToMatch addPlayToMatch;

  StreamSubscription? _matchSubscription;
  StreamSubscription? _playsSubscription;

  MatchBloc({
    required this.matchRepository,
    required this.playRepository,
    required this.addPlayToMatch,
  }) : super(MatchInitial()) {
    on<LoadMatch>(_onLoadMatch);
    on<AddPlayEvent>(_onAddPlay);
    on<MatchUpdatedEvent>(_onMatchUpdated);
  }

  Future<void> _onLoadMatch(LoadMatch event, Emitter<MatchState> emit) async {
    emit(MatchLoading());
    await _matchSubscription?.cancel();
    await _playsSubscription?.cancel();

    // Listen for real-time updates
    _matchSubscription = matchRepository.watchMatch(event.matchId).listen((
      match,
    ) {
      // Internal listener for plays too
      _playsSubscription ??= playRepository
          .watchPlaysByMatch(event.matchId)
          .listen((plays) {
            add(MatchUpdatedEvent(match, plays));
          });
    });
  }

  Future<void> _onAddPlay(AddPlayEvent event, Emitter<MatchState> emit) async {
    try {
      await addPlayToMatch(event.play);
    } catch (e) {
      emit(MatchError('Failed to add play: $e'));
    }
  }

  void _onMatchUpdated(MatchUpdatedEvent event, Emitter<MatchState> emit) {
    if (event.match == null) {
      emit(const MatchError('Match not found'));
    } else {
      emit(MatchLoaded(match: event.match!, plays: event.plays));
    }
  }

  @override
  Future<void> close() {
    _matchSubscription?.cancel();
    _playsSubscription?.cancel();
    return super.close();
  }
}
