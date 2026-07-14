import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/id_generator.dart';

/// Copies picked/recorded media into a permanent, app-owned directory so
/// scene references never break — `image_picker`/`record` often hand
/// back paths in a volatile cache/temp directory that the OS can clear
/// at any time. Every other media service in this feature routes
/// through here before a path is ever written into a [Scene].
///
/// Directory layout under the app's documents directory:
/// `our_story_media/photos/`, `.../videos/`, `.../audio/`,
/// `.../voice/`, `.../thumbnails/`.
abstract class MediaStorageService {
  Future<String> persist(String sourcePath, MediaCategory category);
  Future<void> delete(String path);
  Future<bool> exists(String path);
}

enum MediaCategory { photo, video, audio, voice, thumbnail }

class MediaStorageServiceImpl implements MediaStorageService {
  static const String _rootFolderName = 'our_story_media';

  Future<Directory> _categoryDirectory(MediaCategory category) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final folder = switch (category) {
      MediaCategory.photo => 'photos',
      MediaCategory.video => 'videos',
      MediaCategory.audio => 'audio',
      MediaCategory.voice => 'voice',
      MediaCategory.thumbnail => 'thumbnails',
    };
    final dir = Directory(p.join(documentsDir.path, _rootFolderName, folder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> persist(String sourcePath, MediaCategory category) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source media file does not exist', sourcePath);
    }

    final dir = await _categoryDirectory(category);
    final extension = p.extension(sourcePath);
    final fileName = '${IdGenerator.generate()}$extension';
    final destinationPath = p.join(dir.path, fileName);

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists(String path) => File(path).exists();
}
