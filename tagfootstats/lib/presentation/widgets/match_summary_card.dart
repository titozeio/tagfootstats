import 'package:flutter/material.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/domain/entities/match.dart' as entity;
import 'package:tagfootstats/domain/entities/team.dart';

class MatchSummaryCard extends StatelessWidget {
  final entity.Match match;
  final Team ownTeam;
  final String? tournamentName;

  const MatchSummaryCard({
    super.key,
    required this.match,
    required this.ownTeam,
    this.tournamentName,
  });

  @override
  Widget build(BuildContext context) {
    final isHomeOwnTeam = match.locationType == entity.LocationType.local;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          if (tournamentName != null)
            Text(
              tournamentName!.toUpperCase(),
              style: const TextStyle(
                color: AppColors.nflGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeam(
                isHomeOwnTeam ? ownTeam.name : match.opponentId,
                isHomeOwnTeam,
                match.homeScore,
              ),
              const Text(
                'VS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              _buildTeam(
                !isHomeOwnTeam ? ownTeam.name : match.opponentId,
                !isHomeOwnTeam,
                match.awayScore,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeam(String name, bool isHighlight, int score) {
    return Column(
      children: [
        Text(
          name.toUpperCase(),
          style: TextStyle(
            color: isHighlight ? AppColors.nflGold : Colors.white,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
