import '../../../../core/utils/result.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/scene_repository.dart';

/// Deletes a chapter. Scenes that were linked to it (`Scene.chapterId`)
/// are *not* deleted — they simply fall back to ungrouped/legacy-label
/// grouping, exactly like a scene that was never linked to a chapter at
/// all. Deleting a chapter is never destructive to the story itself.
class DeleteChapter {
  final ChapterRepository chapterRepository;
  final SceneRepository sceneRepository;
  const DeleteChapter(this.chapterRepository, this.sceneRepository);

  Future<Result<void>> call(String chapterId) async {
    final scenesResult = sceneRepository.getAllScenes();
    final scenes = scenesResult.dataOrNull ?? const [];

    for (final scene in scenes.where((s) => s.chapterId == chapterId)) {
      await sceneRepository.saveScene(scene.copyWith(chapterId: ''));
    }

    return chapterRepository.deleteChapter(chapterId);
  }
}
