import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Green Theme
  static const Color primary = Color(0xFF00E676); // Bright Emerald Green
  static const Color primaryDark = Color(0xFF00C853);
  static const Color primaryLight = Color(0xFF69F0AE); // Light green
  static const Color accent = Color(
    0xFF00BFA5,
  ); // Teal-green accent (instead of gold)
  static const Color accentLight = Color(0xFF64FFDA); // Light teal

  // Background Colors - Black Theme
  static const Color background = Color(0xFF050505); // Deep Black
  static const Color card = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF252525);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);

  // Status Colors - All green-based
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC107); // Softer yellow
  static const Color info = Color(
    0xFF00BCD4,
  ); // Cyan (closer to green spectrum)

  // Secondary colors for variety (green spectrum)
  static const Color secondary = Color(0xFF00BFA5); // Teal
  static const Color secondaryDark = Color(0xFF00897B);
  static const Color tertiary = Color(0xFF26A69A); // Muted teal

  // Gradients - All green themed
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)], // Green to teal
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA5), Color(0xFF00897B)], // Teal gradient
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E1E), Color(0xFF0D0D0D)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26FFFFFF), // White with 15% opacity
      Color(0x0DFFFFFF), // White with 5% opacity
    ],
  );

  static const LinearGradient greenGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x2600E676), // Green with 15% opacity
      Color(0x0D00E676), // Green with 5% opacity
    ],
  );
}
