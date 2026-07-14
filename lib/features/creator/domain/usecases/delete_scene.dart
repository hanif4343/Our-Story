import '../../../../core/utils/result.dart';
import '../repositories/scene_repository.dart';

class DeleteScene {
  final SceneRepository repository;
  const DeleteScene(this.repository);

  Future<Result<void>> call(String sceneId) => repository.deleteScene(sceneId);
}
