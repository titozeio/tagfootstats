import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';

class AggregatedStats {
  final List<TeamStatsAggregate> teamStats;
  final List<PlayerStatsAggregate> playerStats;

  const AggregatedStats({
    required this.teamStats,
    required this.playerStats,
  });
}

class TeamStatsAggregate {
  final String teamRef;
  final String teamName;
  int matches = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;
  int totalYards = 0;
  int passes = 0;
  int runs = 0;
  int sacks = 0;
  int sacksReceived = 0;
  int fumbles = 0;
  int fouls = 0;
  int touchdowns = 0;
  int noPat = 0;
  int pat1 = 0;
  int pat2 = 0;
  int flagPulls = 0;
  int interceptions = 0;
  int batted = 0;
  int safeties = 0;

  TeamStatsAggregate({
    required this.teamRef,
    required this.teamName,
  });
}

class PlayerStatsAggregate {
  final String playerId;
  final String teamRef;
  final String teamName;
  final String playerName;
  final int dorsal;
  final String? photoUrl;
  int points = 0;
  int yards = 0;
  int passes = 0;
  int runs = 0;
  int sacks = 0;
  int fumbles = 0;
  int fouls = 0;
  int touchdowns = 0;
  int pat1 = 0;
  int pat2 = 0;
  int flagPulls = 0;
  int interceptions = 0;
  int batted = 0;
  int safeties = 0;

  PlayerStatsAggregate({
    required this.playerId,
    required this.teamRef,
    required this.teamName,
    required this.playerName,
    required this.dorsal,
    required this.photoUrl,
  });
}

AggregatedStats aggregateStats({
  required List<Match> matches,
  required List<Play> plays,
  required String ownTeamId,
  required String ownTeamName,
  required Map<String, String> teamNamesById,
  required List<Player> players,
}) {
  final matchById = {for (final match in matches) match.id: match};
  final playerById = {for (final player in players) player.id: player};
  final teamStatsByRef = <String, TeamStatsAggregate>{};
  final playerStatsById = <String, PlayerStatsAggregate>{};

  TeamStatsAggregate ensureTeam(String teamRef) {
    return teamStatsByRef.putIfAbsent(
      teamRef,
      () => TeamStatsAggregate(
        teamRef: teamRef,
        teamName: teamRef == ownTeamId
            ? ownTeamName
            : resolveTeamName(teamRef, teamNamesById),
      ),
    );
  }

  PlayerStatsAggregate ensurePlayer(Player player, String teamRef) {
    return playerStatsById.putIfAbsent(
      player.id,
      () => PlayerStatsAggregate(
        playerId: player.id,
        teamRef: teamRef,
        teamName: teamRef == ownTeamId
            ? ownTeamName
            : resolveTeamName(teamRef, teamNamesById),
        playerName: player.fullName,
        dorsal: player.dorsal,
        photoUrl: player.photoUrl,
      ),
    );
  }

  ensureTeam(ownTeamId);
  for (final match in matches) {
    final opponentRef = canonicalizeTeamReference(
      match.opponentId,
      teamNamesById,
    );
    final ownStats = ensureTeam(ownTeamId);
    final opponentStats = ensureTeam(opponentRef);
    ownStats.matches++;
    opponentStats.matches++;

    final ownIsHome = match.locationType != LocationType.visitante;
    final ownPoints = ownIsHome ? match.homeScore : match.awayScore;
    final opponentPoints = ownIsHome ? match.awayScore : match.homeScore;

    ownStats.pointsFor += ownPoints;
    ownStats.pointsAgainst += opponentPoints;
    opponentStats.pointsFor += opponentPoints;
    opponentStats.pointsAgainst += ownPoints;
  }

  for (final player in players) {
    final teamRef = canonicalizeTeamReference(player.teamId, teamNamesById);
    ensureTeam(teamRef);
    ensurePlayer(player, teamRef);
  }

  for (final play in plays) {
    final match = matchById[play.matchId];
    if (match == null) {
      continue;
    }

    final opponentRef = canonicalizeTeamReference(
      match.opponentId,
      teamNamesById,
    );
    final offenseTeamRef = _resolveOffenseTeamRef(
      play: play,
      ownTeamId: ownTeamId,
      opponentTeamRef: opponentRef,
    );
    final defenseTeamRef = offenseTeamRef == ownTeamId
        ? opponentRef
        : ownTeamId;
    final offenseStats = ensureTeam(offenseTeamRef);
    final defenseStats = ensureTeam(defenseTeamRef);

    offenseStats.totalYards += play.yardas;

    switch (play.action) {
      case 'PASE':
        offenseStats.passes++;
        if (play.outcome.toUpperCase().contains('INTERCEPTADO')) {
          defenseStats.interceptions++;
        }
        break;
      case 'CARRERA':
        offenseStats.runs++;
        break;
      case 'SACK':
        defenseStats.sacks++;
        offenseStats.sacksReceived++;
        break;
      case 'FUMBLE':
        offenseStats.fumbles++;
        break;
      case 'FALTA':
        ensureTeam(
          _resolvePenalizingTeamRef(
            play: play,
            ownTeamId: ownTeamId,
            opponentTeamRef: opponentRef,
            fallbackRef: offenseTeamRef,
          ),
        ).fouls++;
        break;
      case 'FLAG QUITADO':
        defenseStats.flagPulls++;
        break;
      case 'INTERCEPCIÓN':
        defenseStats.interceptions++;
        break;
      case 'BATTED':
        defenseStats.batted++;
        break;
      case 'SAFETY':
        ensureTeam(
          _resolveScoringTeamRef(
            play: play,
            ownTeamId: ownTeamId,
            opponentTeamRef: opponentRef,
            defaultRef: defenseTeamRef,
          ),
        ).safeties++;
        break;
    }

    if (play.phase == PlayPhase.extraPoint && play.points == 0) {
      offenseStats.noPat++;
    }

    if (play.points > 0) {
      final scoringTeamRef = _resolveScoringTeamRef(
        play: play,
        ownTeamId: ownTeamId,
        opponentTeamRef: opponentRef,
        defaultRef: play.action == 'SAFETY' ? defenseTeamRef : offenseTeamRef,
      );
      final scoringStats = ensureTeam(scoringTeamRef);
      if (play.action != 'SAFETY' && play.points >= 6) {
        scoringStats.touchdowns++;
      } else if (play.action != 'SAFETY' && play.points == 1) {
        scoringStats.pat1++;
      } else if (play.action != 'SAFETY' && play.points == 2) {
        scoringStats.pat2++;
      }
    }

    _applyPlayerStats(
      play: play,
      offenseTeamRef: offenseTeamRef,
      defenseTeamRef: defenseTeamRef,
      ownTeamId: ownTeamId,
      opponentTeamRef: opponentRef,
      playerById: playerById,
      ensurePlayer: ensurePlayer,
    );
  }

  final orderedTeams = teamStatsByRef.values.toList()
    ..sort((a, b) {
      if (a.teamRef == ownTeamId) {
        return -1;
      }
      if (b.teamRef == ownTeamId) {
        return 1;
      }
      return a.teamName.compareTo(b.teamName);
    });

  final orderedPlayers = playerStatsById.values
      .where((player) => _playerHasRegisteredStats(player))
      .toList()
    ..sort((a, b) {
      final teamCompare = a.teamName.compareTo(b.teamName);
      if (teamCompare != 0) {
        return teamCompare;
      }
      return a.playerName.compareTo(b.playerName);
    });

  return AggregatedStats(
    teamStats: orderedTeams,
    playerStats: orderedPlayers,
  );
}

String _resolveOffenseTeamRef({
  required Play play,
  required String ownTeamId,
  required String opponentTeamRef,
}) {
  if (play.phase == PlayPhase.ataque) {
    return ownTeamId;
  }
  if (play.phase == PlayPhase.defensa) {
    return opponentTeamRef;
  }
  if (play.scoringTeamId == opponentTeamRef) {
    return opponentTeamRef;
  }
  if (play.opponentInvolvedPlayerIds.isNotEmpty &&
      play.involvedPlayerIds.isEmpty) {
    return opponentTeamRef;
  }
  return ownTeamId;
}

String _resolveScoringTeamRef({
  required Play play,
  required String ownTeamId,
  required String opponentTeamRef,
  required String defaultRef,
}) {
  if (play.scoringTeamId == opponentTeamRef) {
    return opponentTeamRef;
  }
  if (play.scoringTeamId == ownTeamId || play.scoringTeamId == null) {
    return defaultRef == opponentTeamRef && play.scoringTeamId == ownTeamId
        ? ownTeamId
        : defaultRef;
  }
  return defaultRef;
}

String _resolvePenalizingTeamRef({
  required Play play,
  required String ownTeamId,
  required String opponentTeamRef,
  required String fallbackRef,
}) {
  switch (play.penalizingTeamId) {
    case 'OWN':
      return ownTeamId;
    case 'OPPONENT':
      return opponentTeamRef;
    case null:
      return fallbackRef;
    default:
      return canonicalizeTeamReference(play.penalizingTeamId!, {
        ownTeamId: ownTeamId,
        opponentTeamRef: opponentTeamRef,
      });
  }
}

void _applyPlayerStats({
  required Play play,
  required String offenseTeamRef,
  required String defenseTeamRef,
  required String ownTeamId,
  required String opponentTeamRef,
  required Map<String, Player> playerById,
  required PlayerStatsAggregate Function(Player player, String teamRef)
  ensurePlayer,
}) {
  void applyToPlayer({
    required String playerId,
    required String teamRef,
    required bool isOnOffense,
  }) {
    final player = playerById[playerId];
    if (player == null) {
      return;
    }
    final stats = ensurePlayer(player, teamRef);

    if (isOnOffense) {
      stats.yards += play.yardas;
    }

    if (play.points > 0) {
      final scoringTeamRef = _resolveScoringTeamRef(
        play: play,
        ownTeamId: ownTeamId,
        opponentTeamRef: opponentTeamRef,
        defaultRef: play.action == 'SAFETY' ? defenseTeamRef : offenseTeamRef,
      );
      if (scoringTeamRef == teamRef) {
        stats.points += play.points;
        if (play.action != 'SAFETY' && play.points >= 6) {
          stats.touchdowns++;
        } else if (play.action != 'SAFETY' && play.points == 1) {
          stats.pat1++;
        } else if (play.action != 'SAFETY' && play.points == 2) {
          stats.pat2++;
        }
      }
    }

    switch (play.action) {
      case 'PASE':
        if (isOnOffense) {
          stats.passes++;
        } else if (play.outcome.toUpperCase().contains('INTERCEPTADO')) {
          stats.interceptions++;
        }
        break;
      case 'CARRERA':
        if (isOnOffense) {
          stats.runs++;
        }
        break;
      case 'SACK':
        if (!isOnOffense) {
          stats.sacks++;
        }
        break;
      case 'FUMBLE':
        if (isOnOffense) {
          stats.fumbles++;
        }
        break;
      case 'FALTA':
        final penalizingTeamRef = _resolvePenalizingTeamRef(
          play: play,
          ownTeamId: ownTeamId,
          opponentTeamRef: opponentTeamRef,
          fallbackRef: offenseTeamRef,
        );
        if (penalizingTeamRef == teamRef) {
          stats.fouls++;
        }
        break;
      case 'FLAG QUITADO':
        if (!isOnOffense) {
          stats.flagPulls++;
        }
        break;
      case 'INTERCEPCIÓN':
        if (!isOnOffense) {
          stats.interceptions++;
        }
        break;
      case 'BATTED':
        if (!isOnOffense) {
          stats.batted++;
        }
        break;
      case 'SAFETY':
        if (!isOnOffense) {
          stats.safeties++;
        }
        break;
    }
  }

  for (final playerId in play.involvedPlayerIds) {
    final ownOffense = offenseTeamRef == ownTeamId;
    applyToPlayer(
      playerId: playerId,
      teamRef: ownTeamId,
      isOnOffense: ownOffense,
    );
  }

  for (final playerId in play.opponentInvolvedPlayerIds) {
    final opponentOffense = offenseTeamRef == opponentTeamRef;
    applyToPlayer(
      playerId: playerId,
      teamRef: opponentTeamRef,
      isOnOffense: opponentOffense,
    );
  }
}

bool _playerHasRegisteredStats(PlayerStatsAggregate player) {
  return player.points != 0 ||
      player.yards != 0 ||
      player.passes != 0 ||
      player.runs != 0 ||
      player.sacks != 0 ||
      player.fumbles != 0 ||
      player.fouls != 0 ||
      player.touchdowns != 0 ||
      player.pat1 != 0 ||
      player.pat2 != 0 ||
      player.flagPulls != 0 ||
      player.interceptions != 0 ||
      player.batted != 0 ||
      player.safeties != 0;
}
