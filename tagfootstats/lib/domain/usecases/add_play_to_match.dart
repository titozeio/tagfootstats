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
    if (match == null) return;

    // 3. Calculate new score (Simple logic for now, can be expanded)
    // Points are already included in the Play entity from the UI/Bloc logic
    int newHomeScore = match.homeScore;
    int newAwayScore = match.awayScore;

    // Optimization: In a real app, we'd check which team performed the action.
    // For now, we'll assume the 'points' field in Play is for the 'Home' team (the user's team)
    // unless specified otherwise.
    // TODO: Implement more robust score logic based on 'isOwnTeam' and phase.

    newHomeScore += play.points;

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
