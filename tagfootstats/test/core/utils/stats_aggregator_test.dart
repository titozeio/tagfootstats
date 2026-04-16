import 'package:flutter_test/flutter_test.dart';
import 'package:tagfootstats/core/utils/stats_aggregator.dart';
import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';

void main() {
  group('team reference utils', () {
    test(
      'resolveTeamName uses the registered team name when the reference is an id',
      () {
        expect(resolveTeamName('opp_1', {'opp_1': 'Spartans'}), 'Spartans');
      },
    );

    test(
      'canonicalizeTeamReference converts a stored team name back to its team id',
      () {
        expect(
          canonicalizeTeamReference('Spartans', {'opp_1': 'Spartans'}),
          'opp_1',
        );
      },
    );
  });

  /// Helpers
  Match buildMatch({
    String id = 'm1',
    String opponentId = 'opp_1',
    LocationType locationType = LocationType.local,
    int homeScore = 0,
    int awayScore = 0,
  }) {
    return Match(
      id: id,
      tournamentId: 't1',
      opponentId: opponentId,
      dateTime: DateTime(2026, 4, 16),
      locationType: locationType,
      homeScore: homeScore,
      awayScore: awayScore,
    );
  }

  AggregatedStats aggregate({
    required List<Play> plays,
    List<Match>? matches,
    List<Player>? players,
    int homeScore = 0,
    int awayScore = 0,
  }) {
    final match = buildMatch(homeScore: homeScore, awayScore: awayScore);
    return aggregateStats(
      matches: matches ?? [match],
      plays: plays,
      ownTeamId: 'own_team',
      ownTeamName: 'Wolves',
      teamNamesById: const {'opp_1': 'Spartans'},
      players: players ?? [],
    );
  }

  TeamStatsAggregate findTeam(AggregatedStats result, String ref) {
    return result.teamStats.firstWhere((t) => t.teamRef == ref);
  }

  group('New user-perspective model', () {
    test(
      'ataque play credits own team — interception by opponent counts for opponent',
      () {
        final plays = [
          const Play(
            id: 'p1',
            matchId: 'm1',
            phase: PlayPhase.ataque,
            minute: 3,
            action: 'PASE',
            outcome: 'PASE INTERCEPTADO',
            yardas: 0,
          ),
        ];

        final result = aggregate(plays: plays);
        final own = findTeam(result, 'own_team');
        final opp = findTeam(result, 'opp_1');

        // We threw the pick: own team records passesIntercepted
        expect(own.passesIntercepted, 1);
        // Opponent gets the interception credit
        expect(opp.interceptions, 1);
        // Total passes count = 1
        expect(own.passes, 1);
      },
    );

    test(
      'defensa play: INTERCEPCIÓN credits own team (we intercepted the rival)',
      () {
        final plays = [
          const Play(
            id: 'p1',
            matchId: 'm1',
            phase: PlayPhase.defensa,
            minute: 5,
            action: 'INTERCEPCIÓN',
            outcome: 'EXITO',
          ),
        ];

        final result = aggregate(plays: plays);
        final own = findTeam(result, 'own_team');

        expect(own.interceptions, 1);
      },
    );

    test('defensa play: SACK credits own team (we sacked the rival QB)', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 7,
          action: 'SACK',
          outcome: 'SACK',
        ),
      ];

      final result = aggregate(plays: plays);
      final own = findTeam(result, 'own_team');
      final opp = findTeam(result, 'opp_1');

      expect(own.sacks, 1);
      expect(opp.sacksReceived, 1);
    });

    test(
      'ataque SACK: we got sacked — opponent gets sack, we get sacksReceived',
      () {
        final plays = [
          const Play(
            id: 'p1',
            matchId: 'm1',
            phase: PlayPhase.ataque,
            minute: 7,
            action: 'SACK',
            outcome: 'SACK',
          ),
        ];

        final result = aggregate(plays: plays);
        final own = findTeam(result, 'own_team');
        final opp = findTeam(result, 'opp_1');

        expect(own.sacksReceived, 1);
        expect(opp.sacks, 1);
      },
    );

    test('defensa TD (rival scored) credits opponent via scoringTeamId', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 10,
          action: 'FLAG QUITADO', // defensive play
          outcome: 'TD RIVAL',
          points: 6,
          scoringTeamId: 'opp_1',
        ),
      ];

      final result = aggregate(plays: plays);
      final own = findTeam(result, 'own_team');
      final opp = findTeam(result, 'opp_1');

      expect(opp.touchdowns, 1);
      expect(own.touchdowns, 0);
    });
  });

  group('Pass breakdown (COM/INC/INT)', () {
    test('PASE COMPLETO increments passesComplete', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 1,
          action: 'PASE',
          outcome: 'PASE COMPLETO',
          yardas: 15,
        ),
      ];

      final result = aggregate(plays: plays);
      final own = findTeam(result, 'own_team');
      expect(own.passesComplete, 1);
      expect(own.passesIncomplete, 0);
      expect(own.passesIntercepted, 0);
      expect(own.passes, 1);
    });

    test('PASE INCOMPLETO increments passesIncomplete', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 2,
          action: 'PASE',
          outcome: 'PASE INCOMPLETO',
        ),
      ];

      final result = aggregate(plays: plays);
      final own = findTeam(result, 'own_team');
      expect(own.passesComplete, 0);
      expect(own.passesIncomplete, 1);
      expect(own.passes, 1);
    });

    test(
      'PASE INTERCEPTADO increments passesIntercepted and opponent interceptions',
      () {
        final plays = [
          const Play(
            id: 'p1',
            matchId: 'm1',
            phase: PlayPhase.ataque,
            minute: 3,
            action: 'PASE',
            outcome: 'PASE INTERCEPTADO',
          ),
        ];

        final result = aggregate(plays: plays);
        final own = findTeam(result, 'own_team');
        final opp = findTeam(result, 'opp_1');
        expect(own.passesIntercepted, 1);
        expect(opp.interceptions, 1);
      },
    );

    test('player stats track COM/INC/INT individually', () {
      const qb = Player(
        id: 'qb1',
        teamId: 'own_team',
        firstName: 'Tom',
        lastName: 'QB',
        dorsal: 12,
      );

      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 1,
          action: 'PASE',
          outcome: 'PASE COMPLETO',
          involvedPlayerIds: ['qb1'],
          yardas: 10,
        ),
        const Play(
          id: 'p2',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 2,
          action: 'PASE',
          outcome: 'PASE INCOMPLETO',
          involvedPlayerIds: ['qb1'],
        ),
      ];

      final result = aggregate(plays: plays, players: [qb]);
      final qbStats = result.playerStats.firstWhere((p) => p.playerId == 'qb1');
      expect(qbStats.passesComplete, 1);
      expect(qbStats.passesIncomplete, 1);
      expect(qbStats.passes, 2);
    });
  });

  group('New defensive plays', () {
    test('AVANCE MÁXIMO increments own maxAdvances', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 5,
          action: 'AVANCE MÁXIMO',
          outcome: 'AVANCE MÁXIMO',
        ),
      ];

      final result = aggregate(plays: plays);
      expect(findTeam(result, 'own_team').maxAdvances, 1);
    });

    test('FLAG FALLIDO increments own missedFlags', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 5,
          action: 'FLAG FALLIDO',
          outcome: 'FLAG FALLIDO',
        ),
      ];

      final result = aggregate(plays: plays);
      expect(findTeam(result, 'own_team').missedFlags, 1);
    });
  });

  group('OT minute ordering', () {
    test('plays with minute >= 61 sort after regular-time plays', () {
      final plays = [
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 62,
          action: 'CARRERA',
          outcome: 'Success',
        ),
        const Play(
          id: 'p2',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 30,
          action: 'CARRERA',
          outcome: 'Success',
        ),
        const Play(
          id: 'p3',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 61,
          action: 'PASE',
          outcome: 'PASE COMPLETO',
          yardas: 5,
        ),
      ];

      final sorted = List<Play>.from(plays)
        ..sort((a, b) => a.minute.compareTo(b.minute));

      expect(sorted[0].minute, 30);
      expect(sorted[1].minute, 61);
      expect(sorted[2].minute, 62);
    });
  });

  group('Full match aggregation (backwards compat)', () {
    test('separates own-team and opponent statistics correctly', () {
      final match = buildMatch(homeScore: 8, awayScore: 2);

      final plays = [
        // Our TD pass
        const Play(
          id: 'p1',
          matchId: 'm1',
          phase: PlayPhase.ataque,
          minute: 3,
          action: 'PASE',
          outcome: 'PASE COMPLETO',
          yardas: 12,
          points: 6,
          involvedPlayerIds: ['own_qb'],
        ),
        // Our defensive interception
        const Play(
          id: 'p2',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 6,
          action: 'INTERCEPCIÓN',
          outcome: 'EXITO',
          involvedPlayerIds: ['own_db'],
        ),
        // Our defensive SAFETY (we score 2)
        const Play(
          id: 'p3',
          matchId: 'm1',
          phase: PlayPhase.defensa,
          minute: 8,
          action: 'SAFETY',
          outcome: 'SAFETY',
          points: 2,
          involvedPlayerIds: ['own_db'],
        ),
        // Foul on opponent
        const Play(
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
      expect(ownTeam.passesComplete, 1);

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
