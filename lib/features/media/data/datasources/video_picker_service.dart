import 'package:image_picker/image_picker.dart';
import 'media_storage_service.dart';

/// Lets the Creator pick or record a video and returns its *permanent*
/// local file path, already copied into app storage.
abstract class VideoPickerService {
  Future<String?> pickVideo();
  Future<String?> recordVideo();
}

class VideoPickerServiceImpl implements VideoPickerService {
  final ImagePicker _picker;
  final MediaStorageService _storageService;

  VideoPickerServiceImpl({
    ImagePicker? picker,
    required MediaStorageService storageService,
  })  : _picker = picker ?? ImagePicker(),
        _storageService = storageService;

  /// Keeps scene durations reasonable and avoids bloating device storage —
  /// Story Mode clips are meant to be moments, not full videos.
  static const Duration _maxDuration = Duration(minutes: 3);

  @override
  Future<String?> pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: _maxDuration,
    );
    if (picked == null) return null;
    return _storageService.persist(picked.path, MediaCategory.video);
  }

  @override
  Future<String?> recordVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: _maxDuration,
    );
    if (picked == null) return null;
    return _storageService.persist(picked.path, MediaCategory.video);
  }
}
