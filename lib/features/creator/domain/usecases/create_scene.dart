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
    final scenes = existing.dataOrNull ?? const <Scene>[];
    // Base the new order on the highest existing order + 1, not the raw
    // count. If any scenes were ever deleted, or two scenes ended up
    // sharing an order value (e.g. from a past race condition), using
    // the count alone could assign an order that collides with one
    // already in use.
    final nextOrder = scenes.isEmpty ? 0 : (scenes.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1);

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
