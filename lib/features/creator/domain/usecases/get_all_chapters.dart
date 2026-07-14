import '../../../../core/utils/result.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

class GetAllChapters {
  final ChapterRepository repository;
  const GetAllChapters(this.repository);

  Result<List<Chapter>> call() => repository.getAllChapters();
}
