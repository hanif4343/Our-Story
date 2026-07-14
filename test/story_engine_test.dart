import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/features/creator/domain/entities/animation_config.dart';
import 'package:our_story/features/creator/domain/entities/scene.dart';
import 'package:our_story/features/creator/domain/entities/transition_config.dart';
import 'package:our_story/features/creator/domain/entities/transition_type.dart';
import 'package:our_story/features/animation/domain/animation_type.dart';
import 'package:our_story/features/timeline/domain/services/timeline_service.dart';

Scene _scene({
  required String id,
  required int order,
  String chapter = '',
  String? chapterId,
}) {
  final now = DateTime(2026, 1, 1);
  return Scene(
    id: id,
    order: order,
    title: 'Scene $id',
    date: now,
    chapter: chapter,
    chapterId: chapterId,
    storyText: '',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('TimelineService', () {
    const service = TimelineService();

    test('groups contiguous scenes sharing a legacy chapter label together', () {
      final scenes = [
        _scene(id: 'a', order: 0, chapter: 'Chapter 1'),
        _scene(id: 'b', order: 1, chapter: 'Chapter 1'),
        _scene(id: 'c', order: 2, chapter: 'Chapter 2'),
      ];

      final timeline = service.build(scenes);

      expect(timeline.length, 3);
      expect(timeline[0].chapterIndex, 0);
      expect(timeline[1].chapterIndex, 0);
      expect(timeline[2].chapterIndex, 1);
      expect(timeline[0].chapterSceneCount, 2);
      expect(timeline[2].chapterSceneCount, 1);
    });

    test('prefers chapterId over the legacy label when both are present', () {
      final scenes = [
        _scene(id: 'a', order: 0, chapter: 'Old Label', chapterId: 'chapter-1'),
        _scene(id: 'b', order: 1, chapter: 'Different Old Label', chapterId: 'chapter-1'),
      ];

      final timeline = service.build(scenes);

      expect(timeline[0].chapterIndex, timeline[1].chapterIndex);
    });

    test('ungrouped scenes with no chapter label fall back to "Untitled Chapter"', () {
      final scenes = [_scene(id: 'a', order: 0)];
      final timeline = service.build(scenes);
      expect(timeline.single.chapterLabel, 'Untitled Chapter');
    });

    test('non-contiguous runs of the same label count as separate chapters', () {
      final scenes = [
        _scene(id: 'a', order: 0, chapter: 'Chapter 1'),
        _scene(id: 'b', order: 1, chapter: 'Chapter 2'),
        _scene(id: 'c', order: 2, chapter: 'Chapter 1'),
      ];

      final timeline = service.build(scenes);
      expect(timeline[0].chapterIndex, 0);
      expect(timeline[1].chapterIndex, 1);
      expect(timeline[2].chapterIndex, 2);
    });

    test('globalIndex is sequential across the whole timeline', () {
      final scenes = [
        _scene(id: 'a', order: 0, chapter: 'Chapter 1'),
        _scene(id: 'b', order: 1, chapter: 'Chapter 1'),
        _scene(id: 'c', order: 2, chapter: 'Chapter 2'),
      ];
      final timeline = service.build(scenes);
      expect(timeline.map((e) => e.globalIndex), [0, 1, 2]);
    });

    test('chapterCount returns the number of distinct chapter runs', () {
      final scenes = [
        _scene(id: 'a', order: 0, chapter: 'Chapter 1'),
        _scene(id: 'b', order: 1, chapter: 'Chapter 2'),
      ];
      expect(service.chapterCount(scenes), 2);
      expect(service.chapterCount(const []), 0);
    });
  });

  group('AnimationConfig.forType', () {
    test('every renderer-backed type has a positive intensity', () {
      for (final type in AnimationType.values) {
        if (!type.hasRenderer) continue;
        final config = AnimationConfig.forType(type);
        expect(config.intensity, greaterThan(0), reason: '$type should have a positive intensity');
      }
    });

    test('non-renderer types default to zero intensity', () {
      final config = AnimationConfig.forType(AnimationType.fireworks);
      expect(config.intensity, 0);
    });
  });

  group('TransitionConfig.forType', () {
    test('every transition type resolves a positive duration', () {
      for (final type in TransitionType.values) {
        final config = TransitionConfig.forType(type);
        expect(config.duration.inMilliseconds, greaterThan(0));
      }
    });
  });
}
