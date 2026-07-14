import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'media_storage_service.dart';

/// Generates a cached JPEG thumbnail for a video file so Creator Mode's
/// scene list and media pickers can render lightweight previews instead
/// of decoding full video frames on every rebuild.
abstract class ThumbnailService {
  Future<String?> generateForVideo(String videoPath);
}

class ThumbnailServiceImpl implements ThumbnailService {
  final MediaStorageService _storageService;
  ThumbnailServiceImpl({required MediaStorageService storageService}) : _storageService = storageService;

  @override
  Future<String?> generateForVideo(String videoPath) async {
    final thumbnailPath = await vt.VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: vt.ImageFormat.JPEG,
      maxWidth: 320,
      quality: 75,
    );
    if (thumbnailPath == null) return null;
    return _storageService.persist(thumbnailPath, MediaCategory.thumbnail);
  }
}
