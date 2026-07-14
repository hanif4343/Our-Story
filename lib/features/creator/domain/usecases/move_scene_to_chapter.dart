import '../../../../core/utils/result.dart';
import '../entities/scene.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/scene_repository.dart';

/// Moves a scene into a different chapter (or ungroups it entirely when
/// [chapterId] is null), keeping the scene's legacy free-text `chapter`
/// label in sync with the target chapter's title so v1.1.0-era grouping
/// (which reads that label) keeps working for anyone not yet using the
/// new Chapter screens.
class MoveSceneToChapter {
  final SceneRepository sceneRepository;
  final ChapterRepository chapterRepository;
  const MoveSceneToChapter(this.sceneRepository, this.chapterRepository);

  Future<Result<Scene>> call(Scene scene, String? chapterId) async {
    String chapterLabel = '';
    if (chapterId != null) {
      final chapterResult = chapterRepository.getChapterById(chapterId);
      chapterLabel = chapterResult.dataOrNull?.title ?? '';
    }

    final updated = scene.copyWith(
      chapterId: chapterId ?? '',
      chapter: chapterLabel,
      updatedAt: DateTime.now(),
    );

    final result = await sceneRepository.saveScene(updated);
    return result.fold(
      (failure) => Result.failure(failure),
      (_) => Result.success(updated),
    );
  }
}
