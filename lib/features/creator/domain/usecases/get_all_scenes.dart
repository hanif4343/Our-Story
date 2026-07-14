import '../../../../core/utils/result.dart';
import '../entities/scene.dart';
import '../repositories/scene_repository.dart';

/// Returns every scene sorted by [Scene.order].
class GetAllScenes {
  final SceneRepository repository;
  const GetAllScenes(this.repository);

  Result<List<Scene>> call() => repository.getAllScenes();
}
