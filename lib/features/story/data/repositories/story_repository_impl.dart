import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../creator/domain/entities/scene.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_local_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryLocalDataSource localDataSource;
  StoryRepositoryImpl(this.localDataSource);

  @override
  Result<List<Scene>> getTimeline() {
    try {
      final scenes = localDataSource.getTimeline().map((m) => m.toEntity()).toList();
      return Result.success(scenes);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }
}
