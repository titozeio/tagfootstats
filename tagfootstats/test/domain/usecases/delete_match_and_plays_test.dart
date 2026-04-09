import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/usecases/delete_match_and_plays.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

class MockPlayRepository extends Mock implements PlayRepository {}

void main() {
  late MockMatchRepository matchRepository;
  late MockPlayRepository playRepository;
  late DeleteMatchAndPlays deleteMatchAndPlays;

  setUp(() {
    matchRepository = MockMatchRepository();
    playRepository = MockPlayRepository();
    deleteMatchAndPlays = DeleteMatchAndPlays(matchRepository, playRepository);
  });

  test('deletes all plays before deleting the match', () async {
    final plays = [
      const Play(
        id: 'play_1',
        matchId: 'match_1',
        phase: PlayPhase.ataque,
        minute: 1,
        action: 'PASE',
        outcome: 'COMPLETO',
      ),
      const Play(
        id: 'play_2',
        matchId: 'match_1',
        phase: PlayPhase.defensa,
        minute: 2,
        action: 'SACK',
        outcome: 'EXITO',
      ),
    ];

    when(() => playRepository.getPlaysByMatch('match_1')).thenAnswer(
      (_) async => plays,
    );
    when(() => playRepository.deletePlay(any())).thenAnswer((_) async {});
    when(() => matchRepository.deleteMatch('match_1')).thenAnswer((_) async {});

    await deleteMatchAndPlays('match_1');

    verifyInOrder([
      () => playRepository.getPlaysByMatch('match_1'),
      () => playRepository.deletePlay('play_1'),
      () => playRepository.deletePlay('play_2'),
      () => matchRepository.deleteMatch('match_1'),
    ]);
  });
}
