import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../datasources/scene_local_datasource.dart';
import '../models/scene_model.dart';

class SceneRepositoryImpl implements SceneRepository {
  final SceneLocalDataSource localDataSource;

  SceneRepositoryImpl(this.localDataSource);

  @override
  Result<List<Scene>> getAllScenes() {
    try {
      final scenes = localDataSource.getAllScenes().map((m) => m.toEntity()).toList();
      return Result.success(scenes);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Result<Scene> getSceneById(String id) {
    try {
      final model = localDataSource.getSceneById(id);
      if (model == null) return const Result.failure(NotFoundFailure('Scene not found.'));
      return Result.success(model.toEntity());
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveScene(Scene scene) async {
    try {
      await localDataSource.putScene(SceneModel.fromEntity(scene));
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteScene(String id) async {
    try {
      await localDataSource.deleteScene(id);
      return const Result.success(null);
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reorderScenes(List<String> orderedIds) async {
    try {
      await localDataSource.reorderScenes(orderedIds);
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
