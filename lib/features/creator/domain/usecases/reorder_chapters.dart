import '../../../../core/utils/result.dart';
import '../repositories/chapter_repository.dart';

class ReorderChapters {
  final ChapterRepository repository;
  const ReorderChapters(this.repository);

  Future<Result<void>> call(List<String> orderedIds) => repository.reorderChapters(orderedIds);
}
