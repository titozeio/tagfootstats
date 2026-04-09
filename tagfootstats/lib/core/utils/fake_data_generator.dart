import 'package:flutter/material.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';
import 'package:tagfootstats/domain/entities/team.dart';
import 'package:tagfootstats/domain/entities/tournament.dart';
import 'package:tagfootstats/domain/repositories/match_repository.dart';
import 'package:tagfootstats/domain/repositories/play_repository.dart';
import 'package:tagfootstats/domain/repositories/player_repository.dart';
import 'package:tagfootstats/domain/repositories/team_repository.dart';
import 'package:tagfootstats/domain/repositories/tournament_repository.dart';

class FakeDataGenerator {
  static Future<void> generateAll(
    BuildContext context, {
    required TeamRepository teamRepo,
    required PlayerRepository playerRepo,
    required MatchRepository matchRepo,
    required PlayRepository playRepo,
    required TournamentRepository tournamentRepo,
    required String currentTeamId,
  }) async {
    final now = DateTime.now();
    // 0. Create a Fake Tournament
    await tournamentRepo.saveTournament(
      Tournament(
        id: 'tour_fake',
        name: 'TORNEO DE PRUEBA',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30)),
        type: TournamentType.liga,
      ),
    );

    // 1. Create 2 Opponent Teams
    final opponentTeams = [
      Team(
        id: 'opp_1',
        name: 'Spartans',
        isOwnTeam: false,
        logoUrl: 'https://cdn-icons-png.flaticon.com/512/2822/2822101.png',
      ),
      Team(
        id: 'opp_2',
        name: 'Raiders',
        isOwnTeam: false,
        logoUrl: 'https://cdn-icons-png.flaticon.com/512/861/861506.png',
      ),
    ];

    for (var t in opponentTeams) {
      await teamRepo.saveTeam(t);
    }

    // 2. Create some players for current team
    final fakePlayers = [
      Player(
        id: 'p_1',
        teamId: currentTeamId,
        firstName: 'Peyton',
        lastName: 'Manning',
        dorsal: 18,
        position: PlayerPosition.offense,
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Peyton_Manning_2015.jpg/220px-Peyton_Manning_2015.jpg',
      ),
      Player(
        id: 'p_2',
        teamId: currentTeamId,
        firstName: 'Tom',
        lastName: 'Brady',
        dorsal: 12,
        position: PlayerPosition.offense,
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Tom_Brady_2021.jpg/220px-Tom_Brady_2021.jpg',
      ),
      Player(
        id: 'p_3',
        teamId: currentTeamId,
        firstName: 'Ray',
        lastName: 'Lewis',
        dorsal: 52,
        position: PlayerPosition.defense,
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Ray_Lewis_2012.JPG/220px-Ray_Lewis_2012.JPG',
      ),
    ];
    for (var p in fakePlayers) {
      await playerRepo.savePlayer(p);
    }

    // 3. Create 3 fake matches
    // Removed duplicate final now = DateTime.now();
    final match1 = entity.Match(
      id: 'match_fake_1',
      tournamentId: 'tour_fake',
      opponentId: 'opp_1',
      dateTime: now.subtract(const Duration(days: 7)),
      locationType: entity.LocationType.local,
      homeScore: 24,
      awayScore: 14,
    );
    final match2 = entity.Match(
      id: 'match_fake_2',
      tournamentId: 'tour_fake',
      opponentId: 'opp_2',
      dateTime: now.subtract(const Duration(days: 2)),
      locationType: entity.LocationType.visitante,
      homeScore: 7,
      awayScore: 21,
    );

    await matchRepo.saveMatch(match1);
    await matchRepo.saveMatch(match2);

    // 4. Create fake plays
    final fakePlays = [
      Play(
        id: 'pl_1',
        matchId: 'match_fake_1',
        phase: PlayPhase.ataque,
        minute: 5,
        action: 'PASE',
        outcome: 'COMPLETO',
        yardas: 15,
        points: 0,
        involvedPlayerIds: ['p_1', 'p_2'],
      ),
      Play(
        id: 'pl_2',
        matchId: 'match_fake_1',
        phase: PlayPhase.ataque,
        minute: 10,
        action: 'CARRERA',
        outcome: 'EXITO',
        yardas: 8,
        points: 6,
        involvedPlayerIds: ['p_1'],
      ),
      Play(
        id: 'pl_3',
        matchId: 'match_fake_1',
        phase: PlayPhase.defensa,
        minute: 15,
        action: 'FLAG QUITADO',
        outcome: 'EXITO',
        yardas: 0,
        points: 0,
        involvedPlayerIds: ['p_3'],
      ),
      Play(
        id: 'pl_4',
        matchId: 'match_fake_1',
        phase: PlayPhase.defensa,
        minute: 20,
        action: 'SACK',
        outcome: 'EXITO',
        yardas: -5,
        points: 0,
        involvedPlayerIds: ['p_3'],
      ),
      Play(
        id: 'pl_5',
        matchId: 'match_fake_2',
        phase: PlayPhase.ataque,
        minute: 2,
        action: 'PASE',
        outcome: 'INTERCEPTADO',
        yardas: 0,
        points: 0,
        involvedPlayerIds: ['p_1'],
      ),
    ];

    for (var p in fakePlays) {
      await playRepo.savePlay(p);
    }
  }

  static Future<void> deleteAllStats({
    required MatchRepository matchRepo,
    required PlayRepository playRepo,
  }) async {
    final matches = await matchRepo.getMatches();
    for (var m in matches) {
      final plays = await playRepo.getPlaysByMatch(m.id);
      for (var p in plays) {
        await playRepo.deletePlay(p.id);
      }
      await matchRepo.deleteMatch(m.id);
    }
  }
}
