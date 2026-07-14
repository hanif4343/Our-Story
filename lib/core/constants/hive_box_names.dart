/// Centralised Hive box + typeId registry.
///
/// IMPORTANT: Never reuse a typeId once shipped. Always append new ones.
class HiveBoxNames {
  HiveBoxNames._();

  static const String scenesBox = 'scenes_box';
  static const String settingsBox = 'settings_box';
  static const String mediaIndexBox = 'media_index_box';
  static const String timelineBox = 'timeline_box';

  /// v1.2.0 Story Engine: chapters are now first-class persisted
  /// records (`ChapterModel`), separate from the scenes that belong to
  /// them via `Scene.chapterId`.
  static const String chaptersBox = 'chapters_box';

  /// v1.2.0 Story Engine: single-record box holding the top-level
  /// Journey metadata (title, tagline, start/anchor dates) — mirrors
  /// the `settings_box` singleton-record pattern.
  static const String journeyBox = 'journey_box';
}

/// Registry of Hive TypeAdapter ids. Keep sequential & documented.
class HiveTypeIds {
  HiveTypeIds._();

  static const int sceneModel = 0;
  static const int animationType = 1;
  static const int transitionType = 2;
  static const int backgroundType = 3;
  static const int mediaItemModel = 4;
  static const int settingsModel = 5;

  // v1.2.0 Story Engine additions:
  static const int chapterModel = 6;
  static const int letterModel = 7;
  static const int voiceModel = 8;
  static const int journeyModel = 9;

  // v1.3.0 Cinematic Experience Engine additions:
  static const int sceneMilestoneType = 10;
}
