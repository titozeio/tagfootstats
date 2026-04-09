import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/usecases/add_play_to_match.dart';
import 'package:tagfootstats/presentation/bloc/match/match_bloc.dart';

import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

class MockPlayRepository extends Mock implements PlayRepository {}

class MockAddPlayToMatch extends Mock implements AddPlayToMatch {}

class MockPlayerRepository extends Mock implements PlayerRepository {}

class MockTeamRepository extends Mock implements TeamRepository {}

void main() {
  late MatchBloc matchBloc;
  late MockMatchRepository mockMatchRepository;
  late MockPlayRepository mockPlayRepository;
  late MockAddPlayToMatch mockAddPlayToMatch;
  late MockPlayerRepository mockPlayerRepository;
  late MockTeamRepository mockTeamRepository;

  setUp(() {
    mockMatchRepository = MockMatchRepository();
    mockPlayRepository = MockPlayRepository();
    mockAddPlayToMatch = MockAddPlayToMatch();
    mockPlayerRepository = MockPlayerRepository();
    mockTeamRepository = MockTeamRepository();

    matchBloc = MatchBloc(
      matchRepository: mockMatchRepository,
      playRepository: mockPlayRepository,
      playerRepository: mockPlayerRepository,
      teamRepository: mockTeamRepository,
      addPlayToMatch: mockAddPlayToMatch,
    );
  });

  final tMatch = Match(
    id: '1',
    tournamentId: 't1',
    opponentId: 'o1',
    dateTime: DateTime(2026, 1, 1),
    locationType: LocationType.local,
  );

  final tPlay = Play(
    id: 'p1',
    matchId: '1',
    phase: PlayPhase.ataque,
    minute: 10,
    action: 'TD',
    outcome: 'Success',
    points: 6,
  );

  group('MatchBloc', () {
    test('initial state should be MatchInitial', () {
      expect(matchBloc.state, MatchInitial());
    });

    blocTest<MatchBloc, MatchState>(
      'emits [MatchLoading, MatchLoaded] when LoadMatch is successful',
      build: () {
        when(
          () => mockTeamRepository.getOwnTeam(),
        ).thenAnswer((_) async => null);
        when(
          () => mockMatchRepository.watchMatch('1'),
        ).thenAnswer((_) => Stream.value(tMatch));
        when(
          () => mockPlayRepository.watchPlaysByMatch('1'),
        ).thenAnswer((_) => Stream.value([tPlay]));
        return matchBloc;
      },
      act: (bloc) => bloc.add(const LoadMatch('1')),
      expect: () => [
        MatchLoading(),
        MatchLoaded(
          match: tMatch,
          plays: const [],
          players: const [],
          opponentPlayers: const [],
          opponentTeamName: 'o1',
        ),
        MatchLoaded(
          match: tMatch,
          plays: [tPlay],
          players: const [],
          opponentPlayers: const [],
          opponentTeamName: 'o1',
        ),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchError] when match is not found',
      build: () {
        when(
          () => mockTeamRepository.getOwnTeam(),
        ).thenAnswer((_) async => null);
        when(
          () => mockMatchRepository.watchMatch('1'),
        ).thenAnswer((_) => Stream.value(null));
        when(
          () => mockPlayRepository.watchPlaysByMatch('1'),
        ).thenAnswer((_) => Stream.value([]));
        return matchBloc;
      },
      act: (bloc) => bloc.add(const LoadMatch('1')),
      expect: () => [MatchLoading(), const MatchError('Match not found')],
    );
  });
}
