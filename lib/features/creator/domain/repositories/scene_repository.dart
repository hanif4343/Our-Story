import '../../../../core/utils/result.dart';
import '../entities/scene.dart';

/// Domain-facing contract. Presentation & use cases depend only on this
/// interface — never on the Hive-backed implementation directly.
abstract class SceneRepository {
  Result<List<Scene>> getAllScenes();
  Result<Scene> getSceneById(String id);
  Future<Result<void>> saveScene(Scene scene);
  Future<Result<void>> deleteScene(String id);
  Future<Result<void>> reorderScenes(List<String> orderedIds);
}
