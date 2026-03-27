import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScoreboardWidget extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final String? homeTeamId;
  final String? awayTeamId;
  final String quarter;
  final String timeLeft;

  const ScoreboardWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    this.homeTeamId,
    this.awayTeamId,
    this.quarter = '1Q',
    this.timeLeft = '15:00',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }

  Widget _buildTeamSection(String name, int score, {required bool isHome}) {
    final gradient = isHome
        ? const LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF0055AA)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFCC0000), Color(0xFF880000)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          );

    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: isHome
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (isHome) ...[
              _buildScoreText(score),
              const SizedBox(width: 15),
              Expanded(child: _buildTeamName(name, isHome)),
            ] else ...[
              Expanded(child: _buildTeamName(name, isHome)),
              const SizedBox(width: 15),
              _buildScoreText(score),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreText(int score) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Text(
        score.toString().padLeft(2, '0'),
        key: ValueKey<int>(score),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 42,
          color: Colors.white,
          fontFamily: 'Roboto',
          letterSpacing: -2,
        ),
      ),
    );
  }

  Widget _buildTeamName(String name, bool isHome) {
    final teamId = isHome ? homeTeamId : awayTeamId;
    final heroTag = teamId != null
        ? 'team_logo_$teamId'
        : (isHome ? null : 'opponent_$name');

    Widget text = Text(
      name.toUpperCase(),
      textAlign: isHome ? TextAlign.left : TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: Colors.white,
        letterSpacing: 1,
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag, child: text);
    }
    return text;
  }

  Widget _buildGameInfo() {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.symmetric(
          vertical: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.nflGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              quarter,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: AppColors.nflGold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeLeft,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'CRONO',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
