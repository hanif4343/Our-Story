import '../../../creator/domain/entities/scene.dart';
import '../entities/timeline_event.dart';

/// Builds the derived [TimelineEvent] projection from an ordered list of
/// [Scene]s. Consecutive scenes that share the same chapter grouping key
/// (`chapterId` when a scene has been linked to a real [Chapter] record,
/// otherwise the legacy free-text `chapter` label) are treated as one
/// chapter — matching how the Scene List's own drag-to-reorder keeps a
/// chapter's scenes contiguous.
///
/// Pure, synchronous, and framework-free by design — this is domain
/// logic, not a datasource, so it stays trivially unit-testable.
class TimelineService {
  const TimelineService();

  List<TimelineEvent> build(List<Scene> orderedScenes) {
    if (orderedScenes.isEmpty) return const [];

    final events = <TimelineEvent>[];

    String groupKeyFor(Scene scene) {
      if (scene.chapterId != null && scene.chapterId!.isNotEmpty) return 'id:${scene.chapterId}';
      if (scene.chapter.trim().isNotEmpty) return 'label:${scene.chapter.trim()}';
      return 'ungrouped';
    }

    String labelFor(Scene scene) {
      if (scene.chapter.trim().isNotEmpty) return scene.chapter.trim();
      return 'Untitled Chapter';
    }

    // First pass: split into contiguous chapter runs.
    final runs = <List<Scene>>[];
    String? currentKey;
    for (final scene in orderedScenes) {
      final key = groupKeyFor(scene);
      if (currentKey == null || key != currentKey) {
        runs.add([scene]);
        currentKey = key;
      } else {
        runs.last.add(scene);
      }
    }

    // Second pass: flatten runs into indexed TimelineEvents.
    int globalIndex = 0;
    for (int chapterIndex = 0; chapterIndex < runs.length; chapterIndex++) {
      final run = runs[chapterIndex];
      final label = labelFor(run.first);
      for (int i = 0; i < run.length; i++) {
        events.add(TimelineEvent(
          scene: run[i],
          globalIndex: globalIndex,
          chapterIndex: chapterIndex,
          sceneIndexInChapter: i,
          chapterSceneCount: run.length,
          chapterLabel: label,
        ));
        globalIndex++;
      }
    }

    return events;
  }

  /// Total number of distinct chapters represented in [orderedScenes].
  int chapterCount(List<Scene> orderedScenes) {
    if (orderedScenes.isEmpty) return 0;
    return build(orderedScenes).map((e) => e.chapterIndex).toSet().length;
  }
}
