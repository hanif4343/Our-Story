import '../../../../core/utils/result.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

/// Renames a chapter's title/subtitle without touching its order.
class RenameChapter {
  final ChapterRepository repository;
  const RenameChapter(this.repository);

  Future<Result<Chapter>> call(Chapter chapter, {required String title, String? subtitle}) async {
    final updated = chapter.copyWith(
      title: title,
      subtitle: subtitle ?? chapter.subtitle,
      updatedAt: DateTime.now(),
    );
    final result = await repository.saveChapter(updated);
    return result.fold(
      (failure) => Result.failure(failure),
      (_) => Result.success(updated),
    );
  }
}
