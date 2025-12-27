import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00E676); // Bright Emerald Green
  static const Color primaryDark = Color(0xFF00C853);
  static const Color accent = Color(0xFFFFD700); // Gold for premium

  // Background Colors
  static const Color background = Color(0xFF050505); // Deep Black
  static const Color card = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);

  // Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);
  static const Color info = Color(0xFF448AFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26FFFFFF), // White with 15% opacity
      Color(0x0DFFFFFF), // White with 5% opacity
    ],
  );
}
