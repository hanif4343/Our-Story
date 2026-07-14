import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../datasources/chapter_local_datasource.dart';
import '../models/chapter_model.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final ChapterLocalDataSource localDataSource;

  ChapterRepositoryImpl(this.localDataSource);

  @override
  Result<List<Chapter>> getAllChapters() {
    try {
      final chapters = localDataSource.getAllChapters().map((m) => m.toEntity()).toList();
      return Result.success(chapters);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Result<Chapter> getChapterById(String id) {
    try {
      final model = localDataSource.getChapterById(id);
      if (model == null) return const Result.failure(NotFoundFailure('Chapter not found.'));
      return Result.success(model.toEntity());
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveChapter(Chapter chapter) async {
    try {
      await localDataSource.putChapter(ChapterModel.fromEntity(chapter));
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteChapter(String id) async {
    try {
      await localDataSource.deleteChapter(id);
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
  Future<Result<void>> reorderChapters(List<String> orderedIds) async {
    try {
      await localDataSource.reorderChapters(orderedIds);
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
