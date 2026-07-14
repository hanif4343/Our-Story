import 'package:image_picker/image_picker.dart';
import 'media_storage_service.dart';

/// Lets the Creator pick one or more photos from the gallery/camera and
/// returns their *permanent* local file paths (already copied into app
/// storage via [MediaStorageService] — never a volatile picker cache path).
abstract class ImagePickerService {
  Future<String?> pickSinglePhoto();
  Future<List<String>> pickMultiplePhotos();
  Future<String?> capturePhoto();
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker;
  final MediaStorageService _storageService;

  ImagePickerServiceImpl({
    ImagePicker? picker,
    required MediaStorageService storageService,
  })  : _picker = picker ?? ImagePicker(),
        _storageService = storageService;

  static const int _maxDimension = 2048;
  static const int _imageQuality = 90;

  @override
  Future<String?> pickSinglePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: _imageQuality,
    );
    if (picked == null) return null;
    return _storageService.persist(picked.path, MediaCategory.photo);
  }

  @override
  Future<List<String>> pickMultiplePhotos() async {
    final picked = await _picker.pickMultiImage(
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: _imageQuality,
    );
    if (picked.isEmpty) return const [];

    final persistedPaths = <String>[];
    for (final file in picked) {
      persistedPaths.add(await _storageService.persist(file.path, MediaCategory.photo));
    }
    return persistedPaths;
  }

  @override
  Future<String?> capturePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: _imageQuality,
    );
    if (picked == null) return null;
    return _storageService.persist(picked.path, MediaCategory.photo);
  }
}
