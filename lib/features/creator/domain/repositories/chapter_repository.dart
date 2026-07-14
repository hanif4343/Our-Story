import '../../../../core/utils/result.dart';
import '../entities/chapter.dart';

/// Domain-facing contract for Chapter persistence — mirrors
/// `SceneRepository`'s shape exactly.
abstract class ChapterRepository {
  Result<List<Chapter>> getAllChapters();
  Result<Chapter> getChapterById(String id);
  Future<Result<void>> saveChapter(Chapter chapter);
  Future<Result<void>> deleteChapter(String id);
  Future<Result<void>> reorderChapters(List<String> orderedIds);
}
