import 'package:flutter/material.dart';

/// Our Story's premium romantic palette.
///
/// Primary   -> Rose Pink   (love, warmth)
/// Secondary -> Gold        (preciousness, celebration)
/// Background-> Dark Blue   (cinematic night-sky feel)
/// Accent    -> White       (clarity, light, contrast)
class AppColors {
  AppColors._();

  // ---- Rose Pink (Primary) ----
  static const Color rosePink = Color(0xFFE8547C);
  static const Color rosePinkLight = Color(0xFFFF87A6);
  static const Color rosePinkDark = Color(0xFFB93659);

  // ---- Gold (Secondary) ----
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3D57C);
  static const Color goldDark = Color(0xFFA5801F);

  // ---- Dark Blue (Background) ----
  static const Color midnightBlue = Color(0xFF0B1026);
  static const Color deepBlue = Color(0xFF141B3C);
  static const Color surfaceBlue = Color(0xFF1E2650);

  // ---- White (Accent) ----
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF5F1EA);
  static const Color mutedWhite = Color(0xFFC9CBDA);

  // ---- Semantic ----
  static const Color success = Color(0xFF4CAF7D);
  static const Color error = Color(0xFFE0555C);
  static const Color warning = Color(0xFFE3A93B);

  /// Signature romantic gradient used behind hero moments.
  static const LinearGradient romanticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [midnightBlue, deepBlue, rosePinkDark],
    stops: [0.0, 0.55, 1.0],
  );

  /// Gold shimmer gradient for celebratory accents (buttons, dividers).
  static const LinearGradient goldShimmerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [goldDark, gold, goldLight, gold, goldDark],
  );

  // ---- v1.5.0 Dynamic Background System ----
  // Milestone-themed "mood" gradients, used by SceneView in place of
  // the generic [romanticGradient] whenever a scene has a
  // SceneMilestoneType set and no photo/video background of its own.
  // These are color-mood treatments rather than photographic scenery
  // (e.g. "sunset park", "wedding stage") since real photo assets can't
  // be authored as source code — each palette is still named after the
  // scene it evokes so the intent is clear in code and in the UI.

  /// Proposal → warm sunset-park mood: dusky rose fading to amber.
  static const LinearGradient proposalMoodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2B1B3D), Color(0xFF7A3B5E), Color(0xFFC97B4A)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Wedding → elegant wedding-stage mood: ivory and gold on deep navy.
  static const LinearGradient weddingMoodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF4A3B5C), Color(0xFFD9C08A)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Pregnancy → warm golden-room mood.
  static const LinearGradient pregnancyMoodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2318), Color(0xFF7A4A2E), Color(0xFFE3A93B)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Baby's Birth → clean bright hospital mood fading into a soft
  /// pastel-nursery glow — the two moods the v1.3.0 milestone spec
  /// already combined into one `SceneMilestoneType.babyBirth`.
  static const LinearGradient babyBirthMoodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E2A3A), Color(0xFF6E8FA8), Color(0xFFE9D6E0)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Family → cozy-home mood: warm terracotta and soft cream.
  static const LinearGradient familyMoodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2E1F1A), Color(0xFF8A5A3C), Color(0xFFE8C9A0)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Anniversary → romantic candle-night mood: deep midnight to
  /// candlelight gold.
  static const LinearGradient anniversaryMoodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1026), Color(0xFF3D1F2E), Color(0xFFB8862E)],
    stops: [0.0, 0.5, 1.0],
  );
}
