import 'package:flutter/material.dart';

/// A deep-space, glassmorphic palette used for the "spatial" UI.
class AppColors {
  AppColors._();

  static const Color spaceDeep = Color(0xFF060A18);
  static const Color spaceMid = Color(0xFF0E1530);
  static const Color primary = Color(0xFF7C9BFF);
  static const Color primaryVariant = Color(0xFF5B6EF5);
  static const Color accent = Color(0xFF34E4C0);
  static const Color accentWarm = Color(0xFFFFB877);

  static const Color background = spaceDeep;
  static const Color surface = Color(0x1AFFFFFF); // translucent glass
  static const Color surfaceBorder = Color(0x33FFFFFF);

  static const Color onBackground = Color(0xFFEAF0FF);
  static const Color secondaryText = Color(0xFFA9B4D0);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorAccent = Color(0xFFFF8A80);

  /// Frosted glass fill used across cards/panels.
  static const Color glassFill = Color(0x1FFFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);
}

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.spaceMid,
    error: AppColors.error,
  ),
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.onBackground,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(color: AppColors.onBackground),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.glassFill,
    hintStyle: const TextStyle(color: AppColors.secondaryText),
    labelStyle: const TextStyle(color: AppColors.secondaryText),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.surfaceBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.surfaceBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
  ),
);
