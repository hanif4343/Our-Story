import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralised typography.
///
/// Font families reference `PlayfairDisplay` (romantic serif, headings)
/// and `Poppins` (clean sans, body). Enable the `fonts:` block in
/// pubspec.yaml once the .ttf assets are added — see README "Fonts".
/// Until then Flutter safely falls back to the platform default font,
/// so the app compiles and runs with these exact styles either way.
///
/// v1.5.0 "Luxury Typography" pass: every existing style name/value
/// keeps working exactly as before (nothing renamed or removed) — this
/// only adds soft shadows to the large display styles and a handful of
/// new premium styles for the redesigned Home Screen and Story ending.
class AppTextStyles {
  AppTextStyles._();

  static const String _serif = 'PlayfairDisplay';
  static const String _sans = 'Poppins';

  /// Soft, low-spread glow used behind large romantic titles — reads as
  /// "premium" without ever looking like a harsh drop shadow.
  static const List<Shadow> _softGlow = [
    Shadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 4)),
    Shadow(color: Color(0x33D4AF37), blurRadius: 30, offset: Offset(0, 0)),
  ];

  static const TextStyle heroTitle = TextStyle(
    fontFamily: _serif,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.softWhite,
    letterSpacing: 0.5,
    height: 1.15,
    shadows: _softGlow,
  );

  /// Even larger display size for the Premium Home Screen's welcome
  /// moment and the Story ending's closing lines (v1.5.0).
  static const TextStyle displayTitle = TextStyle(
    fontFamily: _serif,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.softWhite,
    letterSpacing: 0.6,
    height: 1.1,
    shadows: _softGlow,
  );

  /// A softer companion line beneath [heroTitle]/[displayTitle] (v1.5.0).
  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedWhite,
    letterSpacing: 0.8,
    height: 1.5,
  );

  static const TextStyle sceneTitle = TextStyle(
    fontFamily: _serif,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.softWhite,
    height: 1.2,
    shadows: _softGlow,
  );

  static const TextStyle sceneDate = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.gold,
    letterSpacing: 1.2,
  );

  static const TextStyle storyBody = TextStyle(
    fontFamily: _serif,
    fontSize: 19,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.softWhite,
    height: 1.55,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedWhite,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.mutedWhite,
    letterSpacing: 0.8,
  );

  /// Wider-tracked, uppercase-friendly label for section headers on the
  /// Premium Home Screen (e.g. "FAVORITE MEMORIES") — v1.5.0.
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 2.2,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _sans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.pureWhite,
    letterSpacing: 0.6,
  );

  /// Large tabular-feeling number for countdowns and the ending's stat
  /// tiles (v1.5.0) — e.g. "9" above "Years Together".
  static const TextStyle statNumber = TextStyle(
    fontFamily: _serif,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
    height: 1.0,
    shadows: _softGlow,
  );

  /// Quiet, italic credits-roll line for the cinematic Credits sequence
  /// (v1.5.0) — deliberately understated next to [displayTitle].
  static const TextStyle credits = TextStyle(
    fontFamily: _serif,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.mutedWhite,
    letterSpacing: 0.4,
    height: 1.8,
  );
}
