import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Single Material 3 ThemeData used across Creator & Story modes.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.rosePink,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.gold,
        onSecondary: AppColors.midnightBlue,
        surface: AppColors.surfaceBlue,
        onSurface: AppColors.softWhite,
        error: AppColors.error,
        onError: AppColors.pureWhite,
      ),
      scaffoldBackgroundColor: AppColors.midnightBlue,
      fontFamily: 'Poppins',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.sceneTitle,
        iconTheme: IconThemeData(color: AppColors.softWhite),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTextStyles.heroTitle,
        headlineMedium: AppTextStyles.sceneTitle,
        bodyLarge: AppTextStyles.storyBody,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          foregroundColor: AppColors.pureWhite,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 6,
          shadowColor: AppColors.rosePink.withValues(alpha: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1.4),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mutedWhite,
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.surfaceBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedWhite.withValues(alpha: 0.5)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceBlue,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.deepBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTextStyles.sceneTitle.copyWith(fontSize: 22),
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceBlue,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.softWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: AppColors.mutedWhite.withValues(alpha: 0.15)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.rosePink,
        foregroundColor: AppColors.pureWhite,
      ),
    );
  }
}
