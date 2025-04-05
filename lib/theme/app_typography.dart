import 'package:flutter/material.dart';
import 'app_colors.dart'; // Import colors for potential use in text styles

class AppTypography {
  AppTypography._();

  // RN font sizes (from typography.ts)
  static const double _xs = 12.0;
  static const double _sm = 14.0;
  static const double _md = 16.0;
  static const double _lg = 18.0;
  static const double _xl = 20.0;
  static const double _2xl = 24.0;
  static const double _3xl = 30.0;
  static const double _4xl = 36.0;
  static const double _5xl = 48.0;

  // RN font weights mapped to Flutter FontWeight (from typography.ts)
  static const FontWeight _normal = FontWeight.w400; // '400'
  static const FontWeight _medium = FontWeight.w500; // '500'
  // ignore: unused_field
  static const FontWeight _semibold =
      FontWeight.w600; // '600' - Added for potential mapping
  static const FontWeight _bold = FontWeight.w700; // '700'

  // RN line heights (approximated, Flutter uses multiplier) - We can define these in TextTheme
  // For direct TextStyle, line height is a multiplier of font size.
  // Example: RN lg(18)/lh(28) -> multiplier ~1.55

  // --- Text Style Definitions ---
  // Map RN styles to Flutter TextTheme scale names (Material Design 3)
  // https://m3.material.io/styles/typography/type-scale-tokens

  // RN h1 -> displayLarge (approximate mapping)
  static const TextStyle displayLarge = TextStyle(
    // fontFamily: fontFamily.bold, // Using platform default
    fontSize: _5xl, // 48
    fontWeight: _bold,
    color: AppColors.textPrimary, // Default text color
    // height: 60 / 48, // ~1.25 (lineHeights['5xl'] / fontSizes['5xl'])
  );

  // RN h2 -> displayMedium
  static const TextStyle displayMedium = TextStyle(
    fontSize: _4xl, // 36
    fontWeight: _bold,
    color: AppColors.textPrimary,
    // height: 48 / 36, // ~1.33
  );

  // RN h3 -> displaySmall
  static const TextStyle displaySmall = TextStyle(
    fontSize: _3xl, // 30
    fontWeight: _bold,
    color: AppColors.textPrimary,
    // height: 40 / 30, // ~1.33
  );

  // RN h4 -> headlineLarge
  static const TextStyle headlineLarge = TextStyle(
    fontSize: _2xl, // 24
    fontWeight: _bold, // RN h4 used bold
    color: AppColors.textPrimary,
    // height: 36 / 24, // 1.5
  );

  // RN h5 -> headlineMedium (RN used medium weight)
  static const TextStyle headlineMedium = TextStyle(
    fontSize: _xl, // 20
    fontWeight: _medium, // RN h5 used medium
    color: AppColors.textPrimary,
    // height: 32 / 20, // 1.6
  );

  // RN h6 -> headlineSmall (RN used medium weight)
  static const TextStyle headlineSmall = TextStyle(
    fontSize: _lg, // 18
    fontWeight: _medium, // RN h6 used medium
    color: AppColors.textPrimary,
    // height: 28 / 18, // ~1.55
  );

  // --- Body styles ---
  // RN body1 -> bodyLarge
  static const TextStyle bodyLarge = TextStyle(
    fontSize: _md, // 16
    fontWeight: _normal,
    color: AppColors.textPrimary,
    // height: 24 / 16, // 1.5
  );

  // RN body2 -> bodyMedium
  static const TextStyle bodyMedium = TextStyle(
    fontSize: _sm, // 14
    fontWeight: _normal,
    color: AppColors.textSecondary, // Often secondary color for smaller body
    // height: 20 / 14, // ~1.43
  );

  // RN caption -> bodySmall
  static const TextStyle bodySmall = TextStyle(
    fontSize: _xs, // 12
    fontWeight: _normal,
    color: AppColors.textTertiary, // Often tertiary color for caption
    // height: 16 / 12, // ~1.33
  );

  // --- Other styles ---
  // RN button -> labelLarge
  static const TextStyle labelLarge = TextStyle(
    fontSize: _md, // 16
    fontWeight: _medium, // RN button used medium weight
    color: AppColors.textPrimary, // Or specific button text color
    // height: 24 / 16, // 1.5
  );

  // Title styles (Often used in AppBars etc.) - Map from Material defaults or define
  static const TextStyle titleLarge = TextStyle(
    fontSize: _xl, // 20 or 22 typically
    fontWeight: _normal, // Or _medium
    color: AppColors.textPrimary,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: _md, // 16
    fontWeight: _medium,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: _sm, // 14
    fontWeight: _medium,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );
}
