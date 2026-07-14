import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';
import '../../features/creator/data/datasources/chapter_local_datasource.dart';
import '../../features/creator/data/datasources/scene_local_datasource.dart';
import '../../features/creator/data/repositories/chapter_repository_impl.dart';
import '../../features/creator/data/repositories/scene_repository_impl.dart';
import '../../features/creator/domain/repositories/chapter_repository.dart';
import '../../features/creator/domain/repositories/scene_repository.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/story/data/datasources/story_local_datasource.dart';
import '../../features/story/data/repositories/story_repository_impl.dart';
import '../../features/story/domain/repositories/story_repository.dart';
import '../../features/timeline/data/datasources/journey_local_datasource.dart';
import '../../features/timeline/data/repositories/journey_repository_impl.dart';
import '../../features/timeline/domain/repositories/journey_repository.dart';

/// Root dependency-injection graph. Every feature's ViewModel resolves
/// its repository through these providers instead of constructing
/// concrete classes itself — keeps presentation testable and swappable.

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService.instance);

final sceneLocalDataSourceProvider = Provider<SceneLocalDataSource>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SceneLocalDataSourceImpl(storage.scenesBox);
});

final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  return SceneRepositoryImpl(ref.watch(sceneLocalDataSourceProvider));
});

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsLocalDataSourceImpl(storage.settingsBox);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    ref.watch(settingsLocalDataSourceProvider),
    ref.watch(authServiceProvider),
  );
});

final storyLocalDataSourceProvider = Provider<StoryLocalDataSource>((ref) {
  return StoryLocalDataSourceImpl(ref.watch(sceneLocalDataSourceProvider));
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepositoryImpl(ref.watch(storyLocalDataSourceProvider));
});

// v1.2.0 Story Engine additions:

final chapterLocalDataSourceProvider = Provider<ChapterLocalDataSource>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ChapterLocalDataSourceImpl(storage.chaptersBox);
});

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepositoryImpl(ref.watch(chapterLocalDataSourceProvider));
});

final journeyLocalDataSourceProvider = Provider<JourneyLocalDataSource>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return JourneyLocalDataSourceImpl(storage.journeyBox);
});

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepositoryImpl(ref.watch(journeyLocalDataSourceProvider));
});
