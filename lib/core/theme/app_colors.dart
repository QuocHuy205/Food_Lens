import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════
  // PRIMARY THEME — Green (Food/Nutrition App)
  // ═══════════════════════════════════════════════════════
  static const Color primary = Color(0xFF2E7D32); // Main green
  static const Color primaryDark = Color(0xFF1B5E20); // Dark green
  static const Color primaryLight = Color(0xFF43A047); // Light green
  static const Color accent = Color(0xFFFF6F00); // Orange accent

  // ═══════════════════════════════════════════════════════
  // NEUTRAL COLORS
  // ═══════════════════════════════════════════════════════
  static const Color background = Color(0xFFF5F5F5); // Light grey bg
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);

  // ═══════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF212121); // Main text
  static const Color textSecondary = Color(0xFF757575); // Secondary text
  static const Color textHint = Color(0xFFBDBDBD); // Hint text

  // ═══════════════════════════════════════════════════════
  // BORDER & DIVIDER
  // ═══════════════════════════════════════════════════════
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);

  // ═══════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════
  static const Color success = Color(0xFF43A047); // Green success
  static const Color error = Color(0xFFD32F2F); // Red error
  static const Color warning = Color(0xFFFFA000); // Orange warning
  static const Color info = Color(0xFF2196F3); // Blue info

  // ═══════════════════════════════════════════════════════
  // CALORIE STATUS COLORS
  // ═══════════════════════════════════════════════════════
  static const Color healthyGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color excessRed = Color(0xFFD32F2F);

  // ═══════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
  );
}
