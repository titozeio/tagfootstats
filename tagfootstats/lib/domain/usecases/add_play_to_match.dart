import '../entities/match.dart';
import '../entities/play.dart';
import '../repositories/match_repository.dart';
import '../repositories/play_repository.dart';

class AddPlayToMatch {
  final PlayRepository playRepository;
  final MatchRepository matchRepository;

  AddPlayToMatch(this.playRepository, this.matchRepository);

  Future<void> call(Play play) async {
    // 1. Save the play
    await playRepository.savePlay(play);

    // 2. Fetch the current match state
    final match = await matchRepository.getMatchById(play.matchId);
    if (match == null || play.points == 0) return;

    // 3. Calculate new score
    int newHomeScore = match.homeScore;
    int newAwayScore = match.awayScore;

    // Determine if the points are for the user's team or the opponent
    // scoringTeamId == match.opponentId means it's for the opponent
    final forOpponent = play.scoringTeamId == match.opponentId;

    // Determine which score to update based on locationType
    if (match.locationType == LocationType.local) {
      // Us (Local) vs Opponent (Away)
      if (forOpponent) {
        newAwayScore += play.points;
      } else {
        newHomeScore += play.points;
      }
    } else {
      // Opponent (Local) vs Us (Away)
      if (forOpponent) {
        newHomeScore += play.points;
      } else {
        newAwayScore += play.points;
      }
    }

    final updatedMatch = Match(
      id: match.id,
      tournamentId: match.tournamentId,
      opponentId: match.opponentId,
      dateTime: match.dateTime,
      locationType: match.locationType,
      matchday: match.matchday,
      phase: match.phase,
      homeScore: newHomeScore,
      awayScore: newAwayScore,
    );

    // 4. Update the match score
    await matchRepository.saveMatch(updatedMatch);
  }
}
