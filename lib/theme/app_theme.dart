import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // Define the light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: null, // Use platform-default fonts
    primaryColor: AppColors.primary500, // Main primary color
    // Color Scheme: Defines the overall color palette for components
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary500, // Base color for derivation
      brightness: Brightness.light,
      // Override specific scheme colors:
      primary: AppColors.primary500,
      secondary: AppColors.secondary500,
      // Use surface for component backgrounds like Card, Dialog
      surface: AppColors.white, // Changed from 'background'
      error: AppColors.error,
      onPrimary: AppColors.white, // Text/icons on primary color
      onSecondary: AppColors.white, // Text/icons on secondary color
      // Use onSurface for text/icons on component backgrounds
      onSurface: AppColors.textPrimary, // Changed from 'onBackground'
      onError: AppColors.white, // Text/icons on error color
      // background and onBackground are derived if needed, but we explicitly set scaffoldBackgroundColor
    ),

    // Scaffold Background Color (explicitly set)
    scaffoldBackgroundColor:
        AppColors.backgroundPrimary, // Still use this for the main scaffold
    // Text Theme: Apply the custom text styles
    // NOTE: Removed 'const' here as TextTheme() constructor itself might not be const
    // if properties within AppTypography weren't truly const (though they are in our case).
    // It's safer to remove 'const' unless absolutely sure everything down the chain is const.
    textTheme: TextTheme(
      // Removed 'const'
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge, // Used for buttons by default
      labelMedium: const TextStyle(
        fontWeight: FontWeight.w500,
      ), // Can be const if defined directly
      labelSmall: const TextStyle(
        fontWeight: FontWeight.w500,
      ), // Can be const if defined directly
    ).apply(
      // Apply default text colors
      bodyColor: AppColors.textPrimary, // Default text color for body styles
      displayColor:
          AppColors.textPrimary, // Default text color for display styles
    ),

    // --- Component Themes (Removed 'const' where .copyWith was used) ---
    appBarTheme: AppBarTheme(
      // Removed 'const'
      backgroundColor: AppColors.primary500,
      foregroundColor: AppColors.white,
      elevation: 4.0,
      centerTitle: true,
      // Using .copyWith requires the AppBarTheme constructor NOT to be const
      titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      // StyleFrom results are not const, so ElevatedButtonThemeData cannot be const
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.white,
        // Using .copyWith requires the styleFrom result NOT to be const
        textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      // StyleFrom results are not const
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary500,
        // Using .copyWith requires the styleFrom result NOT to be const
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      // Removed 'const'
      filled: true,
      fillColor: AppColors.neutral100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary500, width: 2.0),
      ),
      // Using .copyWith requires the InputDecorationTheme constructor NOT to be const
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error),
    ),

    cardTheme: CardTheme(
      // Removed 'const' (safer if shape or other properties might become non-const later)
      elevation: 2.0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Define a dark theme similarly if needed
  // static final ThemeData darkTheme = ThemeData(...);
}
