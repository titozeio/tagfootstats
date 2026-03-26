import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/usecases/add_play_to_match.dart';
import 'package:tagfootstats/presentation/bloc/match/match_bloc.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

class MockPlayRepository extends Mock implements PlayRepository {}

class MockAddPlayToMatch extends Mock implements AddPlayToMatch {}

void main() {
  late MatchBloc matchBloc;
  late MockMatchRepository mockMatchRepository;
  late MockPlayRepository mockPlayRepository;
  late MockAddPlayToMatch mockAddPlayToMatch;

  setUp(() {
    mockMatchRepository = MockMatchRepository();
    mockPlayRepository = MockPlayRepository();
    mockAddPlayToMatch = MockAddPlayToMatch();
    matchBloc = MatchBloc(
      matchRepository: mockMatchRepository,
      playRepository: mockPlayRepository,
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
        MatchLoaded(match: tMatch, plays: [tPlay]),
      ],
    );

    blocTest<MatchBloc, MatchState>(
      'emits [MatchError] when match is not found',
      build: () {
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
