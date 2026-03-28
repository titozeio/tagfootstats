import 'package:flutter/material.dart';

class AppColors {
  // NFL Deep Blue
  static const Color primaryBlue = Color(0xFF005BD6); // More vibrant NFL Blue
  static const Color primaryBlueDark = Color(0xFF013369); // Original deep blue
  static const Color primaryBlueLight = Color(0xFF4285F4); // For highlights

  // NFL Red
  static const Color accentRed = Color(0xFFD50A0A);

  // Backgrounds
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Accents & Text
  static const Color nflGold = Color(0xFFB3995D);
  static const Color textMain = Colors.white;
  static const Color textSecondary = Colors.white70;

  // Glassmorphism/Overlay
  static Color glassOverlay = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
}
