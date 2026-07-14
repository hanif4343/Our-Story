import '../../../../core/utils/result.dart';
import '../entities/scene.dart';
import '../repositories/scene_repository.dart';

class UpdateScene {
  final SceneRepository repository;
  const UpdateScene(this.repository);

  Future<Result<Scene>> call(Scene scene) async {
    final updated = scene.copyWith(updatedAt: DateTime.now());
    final result = await repository.saveScene(updated);
    return result.fold(
      (failure) => Result.failure(failure),
      (_) => Result.success(updated),
    );
  }
}
