import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScoreboardWidget extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final String quarter;
  final String timeLeft;

  const ScoreboardWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    this.quarter = '1Q',
    this.timeLeft = '15:00',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home Team Section
          _buildTeamSection(homeTeamName, homeScore, isHome: true),

          // Game Info (Clock/Quarter)
          _buildGameInfo(),

          // Away Team Section
          _buildTeamSection(awayTeamName, awayScore, isHome: false),
        ],
      ),
    );
  }

  Widget _buildTeamSection(String name, int score, {required bool isHome}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isHome ? AppColors.primaryBlue : AppColors.accentRed,
          borderRadius: BorderRadius.only(
            topLeft: isHome ? const Radius.circular(12) : Radius.zero,
            bottomLeft: isHome ? const Radius.circular(12) : Radius.zero,
            topRight: !isHome ? const Radius.circular(12) : Radius.zero,
            bottomRight: !isHome ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: isHome
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (isHome) ...[
              Text(
                name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                score.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              Text(
                score.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        border: Border.symmetric(
          vertical: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quarter,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.nflGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeLeft,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Courier', // Clock usually has mono fonts
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
