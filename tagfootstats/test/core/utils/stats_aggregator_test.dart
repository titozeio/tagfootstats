import 'package:flutter_test/flutter_test.dart';
import 'package:tagfootstats/core/utils/stats_aggregator.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';

void main() {
  group('team reference utils', () {
    test('resolveTeamName uses the registered team name when the reference is an id', () {
      expect(
        resolveTeamName('opp_1', {'opp_1': 'Spartans'}),
        'Spartans',
      );
    });

    test('canonicalizeTeamReference converts a stored team name back to its team id', () {
      expect(
        canonicalizeTeamReference('Spartans', {'opp_1': 'Spartans'}),
        'opp_1',
      );
    });
  });

  group('aggregateStats', () {
    test('separates own-team and opponent statistics correctly', () {
      final match = Match(
        id: 'm1',
        tournamentId: 't1',
        opponentId: 'opp_1',
        dateTime: DateTime(2026, 4, 9),
        locationType: LocationType.local,
        homeScore: 8,
        awayScore: 2,
      );

      final plays = [
        Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 3,
          action: 'PASE',
          outcome: 'PASE COMPLETO',
          yardas: 12,
          points: 6,
          involvedPlayerIds: const ['own_qb'],
        ),
        Play(
          id: 'p2',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 6,
          action: 'INTERCEPCIÓN',
          outcome: 'EXITO',
          opponentInvolvedPlayerIds: const ['opp_wr'],
          involvedPlayerIds: const ['own_db'],
        ),
        Play(
          id: 'p3',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 8,
          action: 'SAFETY',
          outcome: 'SAFETY',
          points: 2,
          involvedPlayerIds: const ['own_db'],
        ),
        Play(
          id: 'p4',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 10,
          action: 'FALTA',
          outcome: 'FALTA: HOLDING',
          penalizingTeamId: 'OPPONENT',
        ),
      ];

      final players = [
        const Player(
          id: 'own_qb',
          teamId: 'own_team',
          firstName: 'Tom',
          lastName: 'QB',
          dorsal: 12,
        ),
        const Player(
          id: 'own_db',
          teamId: 'own_team',
          firstName: 'Ray',
          lastName: 'DB',
          dorsal: 52,
        ),
        const Player(
          id: 'opp_wr',
          teamId: 'opp_1',
          firstName: 'Max',
          lastName: 'WR',
          dorsal: 80,
        ),
      ];

      final aggregated = aggregateStats(
        matches: [match],
        plays: plays,
        ownTeamId: 'own_team',
        ownTeamName: 'Wolves',
        teamNamesById: const {'opp_1': 'Spartans'},
        players: players,
      );

      final ownTeam = aggregated.teamStats.firstWhere(
        (stats) => stats.teamRef == 'own_team',
      );
      final opponent = aggregated.teamStats.firstWhere(
        (stats) => stats.teamRef == 'opp_1',
      );

      expect(ownTeam.teamName, 'Wolves');
      expect(ownTeam.touchdowns, 1);
      expect(ownTeam.safeties, 1);
      expect(ownTeam.interceptions, 1);
      expect(ownTeam.pointsFor, 8);
      expect(ownTeam.totalYards, 12);

      expect(opponent.teamName, 'Spartans');
      expect(opponent.fouls, 1);
      expect(opponent.pointsAgainst, 8);

      final ownDefender = aggregated.playerStats.firstWhere(
        (stats) => stats.playerId == 'own_db',
      );
      expect(ownDefender.interceptions, 1);
      expect(ownDefender.safeties, 1);
      expect(ownDefender.points, 2);
    });
  });
}
