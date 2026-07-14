import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/scene.dart';
import '../repositories/scene_repository.dart';

/// Clones an existing scene into a brand-new scene placed immediately
/// after the source in the timeline. Every media reference (paths),
/// creative choice (animation/transition/background/music), and tag is
/// carried over — only identity fields (id, order, title, timestamps)
/// change, so the Creator can quickly branch a moment into a variant.
class DuplicateScene {
  final SceneRepository repository;
  const DuplicateScene(this.repository);

  Future<Result<Scene>> call(String sourceSceneId) async {
    final sourceResult = repository.getSceneById(sourceSceneId);
    if (sourceResult.isFailure) {
      return Result.failure(sourceResult.failureOrNull!);
    }
    final source = sourceResult.dataOrNull!;

    final allResult = repository.getAllScenes();
    final allScenes = allResult.dataOrNull ?? const <Scene>[];

    final now = DateTime.now();
    final duplicate = source.copyWith(
      id: IdGenerator.generate(),
      order: source.order + 1,
      title: '${source.title} (Copy)',
      createdAt: now,
      updatedAt: now,
    );

    // Shift every scene that came after the source down by one to make
    // room right after it, keeping the whole timeline's ordering
    // contiguous, then persist every affected record.
    final reordered = <Scene>[];
    for (final scene in allScenes) {
      if (scene.id == source.id) {
        reordered.add(scene);
        reordered.add(duplicate);
      } else if (scene.order > source.order) {
        reordered.add(scene.copyWith(order: scene.order + 1));
      } else {
        reordered.add(scene);
      }
    }

    for (final scene in reordered) {
      final saveResult = await repository.saveScene(scene);
      if (saveResult.isFailure) {
        return Result.failure(saveResult.failureOrNull!);
      }
    }

    return Result.success(duplicate);
  }
}
