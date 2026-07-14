import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/features/creator/domain/entities/scene.dart';
import 'package:our_story/features/creator/domain/entities/scene_milestone_type.dart';
import 'package:our_story/features/creator/domain/entities/transition_config.dart';
import 'package:our_story/features/creator/domain/entities/transition_type.dart';
import 'package:our_story/features/timeline/domain/entities/journey.dart';

void main() {
  group('TransitionType.lightFlash (v1.3.0)', () {
    test('has a display name', () {
      expect(TransitionType.lightFlash.displayName, 'Light Flash');
    });

    test('resolves a positive-duration config', () {
      final config = TransitionConfig.forType(TransitionType.lightFlash);
      expect(config.type, TransitionType.lightFlash);
      expect(config.duration.inMilliseconds, greaterThan(0));
    });

    test('every TransitionType value (including new v1.3.0 one) has a unique index', () {
      final indices = TransitionType.values.map((t) => t.index).toSet();
      expect(indices.length, TransitionType.values.length);
    });
  });

  group('SceneMilestoneType', () {
    test('defaults to none for a scene with no milestone specified', () {
      final now = DateTime(2026, 1, 1);
      final scene = Scene(id: '1', order: 0, title: 'x', date: now, storyText: '', createdAt: now, updatedAt: now);
      expect(scene.milestoneType, SceneMilestoneType.none);
    });

    test('copyWith can set a milestone without disturbing other fields', () {
      final now = DateTime(2026, 1, 1);
      final scene = Scene(id: '1', order: 0, title: 'Proposal Day', date: now, storyText: '', createdAt: now, updatedAt: now);
      final updated = scene.copyWith(milestoneType: SceneMilestoneType.proposal);
      expect(updated.milestoneType, SceneMilestoneType.proposal);
      expect(updated.title, 'Proposal Day');
    });

    test('every value has a non-empty display name', () {
      for (final type in SceneMilestoneType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });
  });

  group('Journey (v1.3.0 partner/wedding fields)', () {
    test('defaults partner names and wedding date to empty/null', () {
      final journey = Journey(title: 't', tagline: 'tag', startDate: DateTime(2020), anchorDate: DateTime(2021));
      expect(journey.partnerOneName, '');
      expect(journey.partnerTwoName, '');
      expect(journey.weddingDate, isNull);
    });

    test('copyWith sets partner names and wedding date', () {
      final journey = Journey(title: 't', tagline: 'tag', startDate: DateTime(2020), anchorDate: DateTime(2021));
      final updated = journey.copyWith(
        partnerOneName: 'A',
        partnerTwoName: 'B',
        weddingDate: DateTime(2022, 7, 17),
      );
      expect(updated.partnerOneName, 'A');
      expect(updated.partnerTwoName, 'B');
      expect(updated.weddingDate, DateTime(2022, 7, 17));
    });

    test('clearWeddingDate removes a previously-set wedding date', () {
      final journey = Journey(
        title: 't',
        tagline: 'tag',
        startDate: DateTime(2020),
        anchorDate: DateTime(2021),
        weddingDate: DateTime(2022, 7, 17),
      );
      final cleared = journey.copyWith(clearWeddingDate: true);
      expect(cleared.weddingDate, isNull);
    });
  });
}
