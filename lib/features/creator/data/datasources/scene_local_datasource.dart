import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/scene_model.dart';

/// Direct Hive access for scenes. Repositories depend on this
/// abstraction, never on `Hive` directly — keeps the data source
/// swappable (e.g. for tests) without touching the repository.
abstract class SceneLocalDataSource {
  List<SceneModel> getAllScenes();
  SceneModel? getSceneById(String id);
  Future<void> putScene(SceneModel scene);
  Future<void> deleteScene(String id);
  Future<void> reorderScenes(List<String> orderedIds);
}

class SceneLocalDataSourceImpl implements SceneLocalDataSource {
  final Box<SceneModel> box;

  SceneLocalDataSourceImpl(this.box);

  @override
  List<SceneModel> getAllScenes() {
    try {
      final scenes = box.values.toList();
      scenes.sort((a, b) => a.order.compareTo(b.order));
      return scenes;
    } catch (e) {
      throw StorageException('Failed to read scenes: $e');
    }
  }

  @override
  SceneModel? getSceneById(String id) {
    try {
      return box.values.cast<SceneModel?>().firstWhere(
            (s) => s?.id == id,
            orElse: () => null,
          );
    } catch (e) {
      throw StorageException('Failed to read scene $id: $e');
    }
  }

  @override
  Future<void> putScene(SceneModel scene) async {
    try {
      await box.put(scene.id, scene);
    } catch (e) {
      throw StorageException('Failed to save scene: $e');
    }
  }

  @override
  Future<void> deleteScene(String id) async {
    try {
      final existing = getSceneById(id);
      if (existing == null) {
        throw NotFoundException('Scene $id does not exist.');
      }
      await box.delete(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw StorageException('Failed to delete scene: $e');
    }
  }

  @override
  Future<void> reorderScenes(List<String> orderedIds) async {
    try {
      for (var i = 0; i < orderedIds.length; i++) {
        final scene = getSceneById(orderedIds[i]);
        if (scene != null) {
          scene.order = i;
          await scene.save();
        }
      }
    } catch (e) {
      throw StorageException('Failed to reorder scenes: $e');
    }
  }
}
