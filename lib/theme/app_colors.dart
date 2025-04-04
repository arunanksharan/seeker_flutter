import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Blue Palette (from colors.ts)
  static const Color primary50 = Color(0xFFE3F2FD);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary200 = Color(0xFF90CAF9);
  static const Color primary300 = Color(0xFF64B5F6);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary500 = Color(0xFF2196F3); // Main Primary
  static const Color primary600 = Color(0xFF1E88E5);
  static const Color primary700 = Color(0xFF1976D2);
  static const Color primary800 = Color(0xFF1565C0);
  static const Color primary900 = Color(0xFF0D47A1);

  // Secondary Green Palette (from colors.ts)
  static const Color secondary50 = Color(0xFFE8F5E9);
  static const Color secondary100 = Color(0xFFC8E6C9);
  static const Color secondary200 = Color(0xFFA5D6A7);
  static const Color secondary300 = Color(0xFF81C784);
  static const Color secondary400 = Color(0xFF66BB6A);
  static const Color secondary500 = Color(0xFF4CAF50); // Main Secondary
  static const Color secondary600 = Color(0xFF43A047);
  static const Color secondary700 = Color(0xFF388E3C);
  static const Color secondary800 = Color(0xFF2E7D32);
  static const Color secondary900 = Color(0xFF1B5E20);

  // Neutral Palette (from colors.ts)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Semantic Colors (from colors.ts)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3); // Same as primary500

  // Base Colors (from colors.ts)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent =
      Colors.transparent; // Use Flutter's transparent

  // Background Colors (from colors.ts) - Map to theme properties later
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // white
  static const Color backgroundSecondary = Color(
    0xFFF5F7FA,
  ); // ~neutral100 slightly different hex
  static const Color backgroundTertiary = Color(0xFFEEF2F6); // Custom

  // Text Colors (from colors.ts) - Map to theme properties later
  static const Color textPrimary = Color(0xFF212121); // neutral900
  static const Color textSecondary = Color(0xFF757575); // neutral600
  static const Color textTertiary = Color(0xFF9E9E9E); // neutral500
  static const Color textInverse = Color(0xFFFFFFFF); // white

  // Border Colors (from colors.ts) - Map to theme properties later
  static const Color borderLight = Color(0xFFE0E0E0); // neutral300
  static const Color borderMedium = Color(0xFFBDBDBD); // neutral400
  static const Color borderDark = Color(0xFF9E9E9E); // neutral500
}
