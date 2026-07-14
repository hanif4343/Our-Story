import '../../../../core/utils/result.dart';
import '../../../creator/domain/entities/scene.dart';
import '../repositories/story_repository.dart';

class GetStoryTimeline {
  final StoryRepository repository;
  const GetStoryTimeline(this.repository);

  Result<List<Scene>> call() => repository.getTimeline();
}
