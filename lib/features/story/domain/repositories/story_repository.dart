import '../../../../core/utils/result.dart';
import '../../../creator/domain/entities/scene.dart';

/// Story Mode is strictly read-only — it reuses the same persisted
/// scenes the Creator authored, but exposes them through a dedicated
/// repository so Story presentation never depends on Creator's write
/// surface (CQRS-flavoured separation between the two modes).
abstract class StoryRepository {
  Result<List<Scene>> getTimeline();
}
