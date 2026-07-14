import 'dart:io';

/// Lightweight in-memory registry of media paths already confirmed to
/// exist on disk, so Story Mode / Creator previews can skip redundant
/// `File.exists()` I/O calls when re-rendering the same scene.
abstract class MediaCacheService {
  Future<void> warmUp(List<String> paths);
  Future<void> clear();
}

class MediaCacheServiceImpl implements MediaCacheService {
  final Set<String> _verifiedPaths = {};

  @override
  Future<void> warmUp(List<String> paths) async {
    for (final path in paths) {
      if (_verifiedPaths.contains(path)) continue;
      if (await File(path).exists()) {
        _verifiedPaths.add(path);
      }
    }
  }

  @override
  Future<void> clear() async {
    _verifiedPaths.clear();
  }

  bool isVerified(String path) => _verifiedPaths.contains(path);
}
