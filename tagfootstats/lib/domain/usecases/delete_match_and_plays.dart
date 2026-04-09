import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';

class DeleteMatchAndPlays {
  final MatchRepository matchRepository;
  final PlayRepository playRepository;

  DeleteMatchAndPlays(this.matchRepository, this.playRepository);

  Future<void> call(String matchId) async {
    final plays = await playRepository.getPlaysByMatch(matchId);
    for (final play in plays) {
      await playRepository.deletePlay(play.id);
    }
    await matchRepository.deleteMatch(matchId);
  }
}
