import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/match.dart';
import '../../../domain/entities/play.dart';
import '../../../domain/entities/player.dart';
import '../../../domain/repositories/match_repository.dart';
import '../../../domain/repositories/play_repository.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../../domain/repositories/team_repository.dart';
import '../../../domain/usecases/add_play_to_match.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRepository matchRepository;
  final PlayRepository playRepository;
  final PlayerRepository playerRepository;
  final TeamRepository teamRepository;
  final AddPlayToMatch addPlayToMatch;

  StreamSubscription? _matchSubscription;
  StreamSubscription? _playsSubscription;

  MatchBloc({
    required this.matchRepository,
    required this.playRepository,
    required this.playerRepository,
    required this.teamRepository,
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

    try {
      // 1. Fetch Roster (Home Team)
      final ownTeam = await teamRepository.getOwnTeam();
      List<Player> players = [];
      if (ownTeam != null) {
        players = await playerRepository.getPlayersByTeam(ownTeam.id);
      }

      // 2. Listen for real-time updates of match and plays
      _matchSubscription = matchRepository.watchMatch(event.matchId).listen((
        match,
      ) {
        if (match == null) {
          add(MatchUpdatedEvent(null, const [], players: players));
          return;
        }

        // When we have the match, we start listening for plays if not already
        _playsSubscription ??= playRepository
            .watchPlaysByMatch(event.matchId)
            .listen((plays) {
              add(MatchUpdatedEvent(match, plays, players: players));
            });
      });
    } catch (e) {
      emit(MatchError('Error loading match: $e'));
    }
  }

  Future<void> _onAddPlay(AddPlayEvent event, Emitter<MatchState> emit) async {
    try {
      // 1. Calculate points based on common flag football rules if not provided
      int points = event.play.points;
      if (points == 0) {
        if (event.play.outcome.toLowerCase().contains('touchdown')) points = 6;
        if (event.play.outcome.toLowerCase().contains('extra point 1'))
          points = 1;
        if (event.play.outcome.toLowerCase().contains('extra point 2'))
          points = 2;
        if (event.play.outcome.toLowerCase().contains('safety')) points = 2;
      }

      await addPlayToMatch(event.play);
    } catch (e) {
      emit(MatchError('Failed to add play: $e'));
    }
  }

  void _onMatchUpdated(MatchUpdatedEvent event, Emitter<MatchState> emit) {
    if (event.match == null) {
      emit(const MatchError('Match not found'));
    } else {
      emit(
        MatchLoaded(
          match: event.match!,
          plays: event.plays,
          players: event.players,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _matchSubscription?.cancel();
    _playsSubscription?.cancel();
    return super.close();
  }
}
