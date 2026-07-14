import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_box_names.dart';
import '../../features/animation/domain/animation_type.dart';
import '../../features/creator/data/models/chapter_model.dart';
import '../../features/creator/data/models/letter_model.dart';
import '../../features/creator/data/models/scene_model.dart';
import '../../features/creator/domain/entities/background_type.dart';
import '../../features/creator/domain/entities/scene_milestone_type.dart';
import '../../features/creator/domain/entities/transition_type.dart';
import '../../features/media/data/models/voice_model.dart';
import '../../features/settings/data/models/settings_model.dart';
import '../../features/timeline/data/models/journey_model.dart';

/// Owns Hive lifecycle: adapter registration, box opening/closing.
/// This is the ONLY place Hive.init* / registerAdapter calls should happen.
///
/// Called once from main.dart before runApp().
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _registerAdapters();

    await Future.wait([
      Hive.openBox<SceneModel>(HiveBoxNames.scenesBox),
      Hive.openBox<SettingsModel>(HiveBoxNames.settingsBox),
      Hive.openBox<ChapterModel>(HiveBoxNames.chaptersBox),
      Hive.openBox<JourneyModel>(HiveBoxNames.journeyBox),
    ]);

    _initialized = true;
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTypeIds.sceneModel)) {
      Hive.registerAdapter(SceneModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.animationType)) {
      Hive.registerAdapter(AnimationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.transitionType)) {
      Hive.registerAdapter(TransitionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.backgroundType)) {
      Hive.registerAdapter(BackgroundTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.settingsModel)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }
    // v1.2.0 Story Engine additions:
    if (!Hive.isAdapterRegistered(HiveTypeIds.chapterModel)) {
      Hive.registerAdapter(ChapterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.letterModel)) {
      Hive.registerAdapter(LetterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.voiceModel)) {
      Hive.registerAdapter(VoiceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.journeyModel)) {
      Hive.registerAdapter(JourneyModelAdapter());
    }
    // v1.3.0 Cinematic Experience Engine additions:
    if (!Hive.isAdapterRegistered(HiveTypeIds.sceneMilestoneType)) {
      Hive.registerAdapter(SceneMilestoneTypeAdapter());
    }
  }

  Box<SceneModel> get scenesBox => Hive.box<SceneModel>(HiveBoxNames.scenesBox);
  Box<SettingsModel> get settingsBox => Hive.box<SettingsModel>(HiveBoxNames.settingsBox);
  Box<ChapterModel> get chaptersBox => Hive.box<ChapterModel>(HiveBoxNames.chaptersBox);
  Box<JourneyModel> get journeyBox => Hive.box<JourneyModel>(HiveBoxNames.journeyBox);

  Future<void> closeAll() => Hive.close();
}
