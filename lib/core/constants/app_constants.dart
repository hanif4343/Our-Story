/// Global, non-visual constants for the whole application.
class AppConstants {
  AppConstants._();

  static const String appName = "Our Story";
  static const String appTagline = "Hanif ❤ Santona";

  /// Default names shown on the v1.3.0 Journey Intro's title card,
  /// until the Creator edits them in Settings → Journey.
  static const String partnerOneName = "Mohammad Hanif Sardar";
  static const String partnerTwoName = "Santona Akter";

  /// Default third name credited on the v1.5.0 Story ending's Credits
  /// sequence ("Featuring …"), until the Creator edits it in Settings →
  /// Journey.
  static const String featuredName = "Hosain Sardar Soyad";

  /// The story's canonical start date — October 1, 2017.
  static final DateTime storyStartDate = DateTime(2017, 10, 1);

  /// The wedding date shown on the Journey Intro — July 17, 2022.
  static final DateTime weddingDate = DateTime(2022, 7, 17);

  /// The anniversary / target date this gift commemorates — July 17, 2026.
  static final DateTime storyAnchorDate = DateTime(2026, 7, 17);

  /// Default duration a scene stays on screen in Story Mode before
  /// auto-advancing, when the scene itself doesn't define a custom duration.
  static const Duration defaultSceneDuration = Duration(seconds: 8);

  /// Default cross-scene transition duration.
  static const Duration defaultTransitionDuration = Duration(milliseconds: 900);

  /// Minimum characters required for the creator password.
  static const int minPasswordLength = 4;
}
