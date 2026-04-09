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

  Match? _currentMatch;
  List<Play> _currentPlays = const [];
  List<Player> _players = const [];
  List<Player> _opponentPlayers = const [];
  String _opponentTeamName = '';

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
      // 1. Fetch Roster (Our Team)
      final ownTeam = await teamRepository.getOwnTeam().timeout(
        const Duration(seconds: 10),
      );

      if (ownTeam != null) {
        _players = await playerRepository
            .getPlayersByTeam(ownTeam.id)
            .timeout(const Duration(seconds: 10));
      }

      // 2. Listen for match updates
      _matchSubscription = matchRepository
          .watchMatch(event.matchId)
          .listen(
            (match) async {
              if (match == null) {
                add(
                  MatchUpdatedEvent(
                    null,
                    _currentPlays,
                    players: _players,
                    opponentPlayers: _opponentPlayers,
                    opponentTeamName: _opponentTeamName,
                  ),
                );
                return;
              }

              _currentMatch = match;

              // 3. Load opponent name and roster if match opponentId changed or not loaded
              bool needsRosterUpdate =
                  _opponentPlayers.isEmpty ||
                  (_opponentPlayers.isNotEmpty &&
                      _opponentPlayers.first.teamId != match.opponentId);

              if (needsRosterUpdate || _opponentTeamName.isEmpty) {
                try {
                  // Fetch Team name first
                  final opponentTeam = await teamRepository
                      .getTeamById(match.opponentId)
                      .timeout(const Duration(seconds: 3));
                  if (opponentTeam != null) {
                    _opponentTeamName = opponentTeam.name;
                  } else {
                    // Fallback to the ID itself if team not found (for legacy support)
                    _opponentTeamName = match.opponentId;
                  }

                  // Fetch Roster
                  _opponentPlayers = await playerRepository
                      .getPlayersByTeam(match.opponentId)
                      .timeout(const Duration(seconds: 5));
                } catch (_) {
                  // If fetch fails, keep current name if it's the same ID
                  if (_opponentTeamName.isEmpty) {
                    _opponentTeamName = match.opponentId;
                  }
                }
              }

              _emitUpdate();
            },
            onError: (e) {
              add(
                MatchUpdatedEvent(
                  null,
                  _currentPlays,
                  players: _players,
                  opponentTeamName: _opponentTeamName,
                ),
              );
            },
          );

      // 4. Listen for plays updates
      _playsSubscription = playRepository
          .watchPlaysByMatch(event.matchId)
          .listen(
            (plays) {
              _currentPlays = plays;
              _emitUpdate();
            },
            onError: (e) {
              _emitUpdate();
            },
          );
    } catch (e) {
      emit(MatchError('Error loading match: $e'));
    }
  }

  void _emitUpdate() {
    if (_currentMatch != null) {
      add(
        MatchUpdatedEvent(
          _currentMatch,
          _currentPlays,
          players: _players,
          opponentPlayers: _opponentPlayers,
          opponentTeamName: _opponentTeamName,
        ),
      );
    }
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
      emit(
        MatchLoaded(
          match: event.match!,
          plays: event.plays,
          players: event.players,
          opponentPlayers: event.opponentPlayers,
          opponentTeamName: event.opponentTeamName,
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
