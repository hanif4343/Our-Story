import 'package:equatable/equatable.dart';
import '../../../creator/domain/entities/scene.dart';

/// A single computed step in the Journey → Chapter → Scene hierarchy,
/// used to drive Story Player's progress UI (total progress + chapter
/// progress) and Creator Mode's chapter-grouped Scene List.
///
/// This is a *derived* projection, never persisted itself — it's built
/// by [TimelineService] from the real, persisted [Scene] list (and,
/// once a scene carries a `chapterId`, real [Chapter] records) every
/// time the timeline is loaded.
class TimelineEvent extends Equatable {
  final Scene scene;

  /// Position of this scene within the *entire* journey (0-based).
  final int globalIndex;

  /// Position of this scene's chapter within the journey (0-based).
  final int chapterIndex;

  /// Position of this scene within its own chapter (0-based).
  final int sceneIndexInChapter;

  /// How many scenes exist in this scene's chapter.
  final int chapterSceneCount;

  /// Display label for the chapter this scene belongs to — either the
  /// linked [Chapter]'s title, the scene's legacy free-text `chapter`
  /// label, or a generated "Untitled Chapter" fallback so grouping is
  /// always well-defined even for scenes authored before v1.2.0.
  final String chapterLabel;

  const TimelineEvent({
    required this.scene,
    required this.globalIndex,
    required this.chapterIndex,
    required this.sceneIndexInChapter,
    required this.chapterSceneCount,
    required this.chapterLabel,
  });

  bool get isFirstInChapter => sceneIndexInChapter == 0;
  bool get isLastInChapter => sceneIndexInChapter == chapterSceneCount - 1;

  @override
  List<Object?> get props => [scene.id, globalIndex, chapterIndex, sceneIndexInChapter, chapterSceneCount, chapterLabel];
}
