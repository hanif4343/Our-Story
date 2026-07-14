import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_recorder_service.dart';
import '../../data/datasources/image_picker_service.dart';
import '../../data/datasources/media_cache_service.dart';
import '../../data/datasources/media_storage_service.dart';
import '../../data/datasources/music_picker_service.dart';
import '../../data/datasources/thumbnail_service.dart';
import '../../data/datasources/video_picker_service.dart';

/// Dependency graph for the media pipeline. Kept in its own file (rather
/// than folded into `core/providers/core_providers.dart`) so the media
/// feature stays self-contained and easy to reason about in isolation —
/// consistent with this project's Feature-First Architecture.

final mediaStorageServiceProvider = Provider<MediaStorageService>((ref) {
  return MediaStorageServiceImpl();
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerServiceImpl(storageService: ref.watch(mediaStorageServiceProvider));
});

final videoPickerServiceProvider = Provider<VideoPickerService>((ref) {
  return VideoPickerServiceImpl(storageService: ref.watch(mediaStorageServiceProvider));
});

final musicPickerServiceProvider = Provider<MusicPickerService>((ref) {
  return MusicPickerServiceImpl(storageService: ref.watch(mediaStorageServiceProvider));
});

final audioRecorderServiceProvider = Provider<AudioRecorderService>((ref) {
  return AudioRecorderServiceImpl(storageService: ref.watch(mediaStorageServiceProvider));
});

final thumbnailServiceProvider = Provider<ThumbnailService>((ref) {
  return ThumbnailServiceImpl(storageService: ref.watch(mediaStorageServiceProvider));
});

final mediaCacheServiceProvider = Provider<MediaCacheService>((ref) {
  return MediaCacheServiceImpl();
});
