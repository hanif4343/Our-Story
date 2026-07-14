import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

/// Creates a new chapter, assigning it a fresh id and placing it at the
/// end of the current chapter order.
class CreateChapter {
  final ChapterRepository repository;
  const CreateChapter(this.repository);

  Future<Result<Chapter>> call({required String title, String subtitle = ''}) async {
    final existing = repository.getAllChapters();
    final nextOrder = existing.dataOrNull?.length ?? 0;
    final now = DateTime.now();

    final chapter = Chapter(
      id: IdGenerator.generate(),
      title: title,
      subtitle: subtitle,
      order: nextOrder,
      createdAt: now,
      updatedAt: now,
    );

    final result = await repository.saveChapter(chapter);
    return result.fold(
      (failure) => Result.failure(failure),
      (_) => Result.success(chapter),
    );
  }
}
