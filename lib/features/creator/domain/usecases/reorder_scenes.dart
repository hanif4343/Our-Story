import '../../../../core/utils/result.dart';
import '../repositories/scene_repository.dart';

/// Persists a new scene ordering. [orderedIds] must contain every scene id
/// exactly once, in its new desired order.
class ReorderScenes {
  final SceneRepository repository;
  const ReorderScenes(this.repository);

  Future<Result<void>> call(List<String> orderedIds) => repository.reorderScenes(orderedIds);
}
