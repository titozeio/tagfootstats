import 'package:tagfootstats/core/utils/team_reference_utils.dart';
import 'package:tagfootstats/domain/entities/match.dart';
import 'package:tagfootstats/domain/entities/play.dart';
import 'package:tagfootstats/domain/entities/player.dart';

class AggregatedStats {
  final List<TeamStatsAggregate> teamStats;
  final List<PlayerStatsAggregate> playerStats;

  const AggregatedStats({required this.teamStats, required this.playerStats});
}

class TeamStatsAggregate {
  final String teamRef;
  final String teamName;
  int matches = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;
  int totalYards = 0;
  // Pass breakdown (COM / INC / INT)
  int passesComplete = 0;
  int passesIncomplete = 0;
  int passesIntercepted = 0;
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
  int maxAdvances = 0;
  int missedFlags = 0;

  /// Total passes registered (complete + incomplete + intercepted).
  int get passes => passesComplete + passesIncomplete + passesIntercepted;

  TeamStatsAggregate({required this.teamRef, required this.teamName});
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
  // Pass breakdown (COM / INC / INT)
  int passesComplete = 0;
  int passesIncomplete = 0;
  int passesIntercepted = 0;
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
  int maxAdvances = 0;
  int missedFlags = 0;

  /// Total passes registered (complete + incomplete + intercepted).
  int get passes => passesComplete + passesIncomplete + passesIntercepted;

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

    // ── NEW MODEL: all plays are from the user's team perspective ──────────
    // phase=ataque  → our team is executing an offensive play
    // phase=defensa → our team is executing a defensive play
    // The opponent only ever shows up in stats when their points (scoringTeamId)
    // or their actions are derived from our defensive plays.
    final ownStats = ensureTeam(ownTeamId);
    final opponentStats = ensureTeam(opponentRef);

    // Yardas: always count on the user's team (our yards gained/lost).
    ownStats.totalYards += play.yardas;

    final outcomeUpper = play.outcome.toUpperCase();

    switch (play.action) {
      case 'PASE':
        // Determine pass result from outcome string
        if (outcomeUpper.contains('INTERCEPTADO')) {
          ownStats.passesIntercepted++;
          // The interception is a defensive gain: credit to opponent IF they
          // intercepted (i.e. rival picked our pass). This is an ataque play.
          opponentStats.interceptions++;
        } else if (outcomeUpper.contains('INCOMPLETO')) {
          ownStats.passesIncomplete++;
        } else {
          // COMPLETO (default for any other outcome during a pase)
          ownStats.passesComplete++;
        }
        break;

      case 'CARRERA':
        ownStats.runs++;
        break;

      case 'SACK':
        if (play.phase == PlayPhase.ataque) {
          // We got sacked (offensive play gone wrong)
          ownStats.sacksReceived++;
          opponentStats.sacks++;
        } else {
          // We sacked the rival QB (defensive play)
          ownStats.sacks++;
          opponentStats.sacksReceived++;
        }
        break;

      case 'FUMBLE':
        ownStats.fumbles++;
        break;

      case 'FALTA':
        ensureTeam(
          _resolvePenalizingTeamRef(
            play: play,
            ownTeamId: ownTeamId,
            opponentTeamRef: opponentRef,
            fallbackRef: ownTeamId,
          ),
        ).fouls++;
        break;

      case 'FLAG QUITADO':
        // Our defense pulled the flag
        ownStats.flagPulls++;
        break;

      case 'INTERCEPCIÓN':
        // Our defense intercepted a rival pass
        ownStats.interceptions++;
        break;

      case 'BATTED':
        // Our defense batted a pass
        ownStats.batted++;
        break;

      case 'SAFETY':
        // Our defense caused a safety → we score 2 pts (handled below in scoring)
        ownStats.safeties++;
        break;

      case 'AVANCE MÁXIMO':
        // Rival reached max advance — defensive stat vs. rival
        ownStats.maxAdvances++;
        break;

      case 'FLAG FALLIDO':
        // We missed a flag pull
        ownStats.missedFlags++;
        break;
    }

    // Extra point: no PAT
    if (play.phase == PlayPhase.extraPoint && play.points == 0) {
      ownStats.noPat++;
    }

    // Points scored
    if (play.points > 0) {
      final scoringTeamRef = _resolveScoringTeamRef(
        play: play,
        ownTeamId: ownTeamId,
        opponentTeamRef: opponentRef,
        defaultRef: ownTeamId,
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
      ownTeamId: ownTeamId,
      opponentTeamRef: opponentRef,
      playerById: playerById,
      ensurePlayer: ensurePlayer,
      teamNamesById: teamNamesById,
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

  final orderedPlayers =
      playerStatsById.values
          .where((player) => _playerHasRegisteredStats(player))
          .toList()
        ..sort((a, b) {
          final teamCompare = a.teamName.compareTo(b.teamName);
          if (teamCompare != 0) {
            return teamCompare;
          }
          return a.playerName.compareTo(b.playerName);
        });

  return AggregatedStats(teamStats: orderedTeams, playerStats: orderedPlayers);
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
  required String ownTeamId,
  required String opponentTeamRef,
  required Map<String, Player> playerById,
  required PlayerStatsAggregate Function(Player player, String teamRef)
  ensurePlayer,
  required Map<String, String> teamNamesById,
}) {
  // Under the new model, involvedPlayerIds contains user team players only.
  // opponentInvolvedPlayerIds is no longer used in recording but may exist
  // in legacy data — we still process it for backward compatibility.

  final outcomeUpper = play.outcome.toUpperCase();

  void applyToOwnPlayer(String playerId) {
    final player = playerById[playerId];
    if (player == null) return;
    final stats = ensurePlayer(player, ownTeamId);

    // Yardas always go to the player who executed the play
    stats.yards += play.yardas;

    // Points: whoever's scoringTeamId matches
    if (play.points > 0) {
      final scoringTeamRef = _resolveScoringTeamRef(
        play: play,
        ownTeamId: ownTeamId,
        opponentTeamRef: opponentTeamRef,
        defaultRef: ownTeamId,
      );
      if (scoringTeamRef == ownTeamId) {
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
        if (outcomeUpper.contains('INTERCEPTADO')) {
          stats.passesIntercepted++;
        } else if (outcomeUpper.contains('INCOMPLETO')) {
          stats.passesIncomplete++;
        } else {
          stats.passesComplete++;
        }
        break;
      case 'CARRERA':
        stats.runs++;
        break;
      case 'SACK':
        if (play.phase == PlayPhase.ataque) {
          // We got sacked — nothing to credit the player in offense
        } else {
          stats.sacks++;
        }
        break;
      case 'FUMBLE':
        stats.fumbles++;
        break;
      case 'FALTA':
        final penalizingTeamRef = _resolvePenalizingTeamRef(
          play: play,
          ownTeamId: ownTeamId,
          opponentTeamRef: opponentTeamRef,
          fallbackRef: ownTeamId,
        );
        if (penalizingTeamRef == ownTeamId) {
          stats.fouls++;
        }
        break;
      case 'FLAG QUITADO':
        stats.flagPulls++;
        break;
      case 'INTERCEPCIÓN':
        stats.interceptions++;
        break;
      case 'BATTED':
        stats.batted++;
        break;
      case 'SAFETY':
        stats.safeties++;
        break;
      case 'AVANCE MÁXIMO':
        stats.maxAdvances++;
        break;
      case 'FLAG FALLIDO':
        stats.missedFlags++;
        break;
    }
  }

  for (final playerId in play.involvedPlayerIds) {
    applyToOwnPlayer(playerId);
  }

  // Legacy backward-compat: opponent players in old data
  // We still call ensurePlayer to register them in the player map,
  // but no stat attribution under the new user-perspective model.
  for (final playerId in play.opponentInvolvedPlayerIds) {
    final player = playerById[playerId];
    if (player == null) continue;
    ensurePlayer(player, opponentTeamRef);
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
      player.safeties != 0 ||
      player.maxAdvances != 0 ||
      player.missedFlags != 0;
}
