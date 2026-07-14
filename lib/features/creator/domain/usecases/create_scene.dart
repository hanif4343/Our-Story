import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/scene.dart';
import '../repositories/scene_repository.dart';

/// Creates a new scene, assigning it a fresh id and placing it at the end
/// of the current timeline order.
class CreateScene {
  final SceneRepository repository;
  const CreateScene(this.repository);

  Future<Result<Scene>> call(Scene draft) async {
    final existing = repository.getAllScenes();
    final nextOrder = existing.dataOrNull?.length ?? 0;

    final now = DateTime.now();
    final scene = draft.copyWith(
      id: IdGenerator.generate(),
      order: nextOrder,
      createdAt: now,
      updatedAt: now,
    );

    final result = await repository.saveScene(scene);
    return result.fold(
      (failure) => Result.failure(failure),
      (_) => Result.success(scene),
    );
  }
}
