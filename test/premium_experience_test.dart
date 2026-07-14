import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/features/creator/domain/entities/transition_config.dart';
import 'package:our_story/features/creator/domain/entities/transition_type.dart';
import 'package:our_story/features/timeline/domain/entities/journey.dart';

void main() {
  group('TransitionType (v1.5.0 Advanced Scene Transitions)', () {
    test('all 7 new transition types have display names', () {
      const newTypes = [
        TransitionType.dreamFade,
        TransitionType.romanticBlur,
        TransitionType.heartReveal,
        TransitionType.roseBloom,
        TransitionType.goldenFlash,
        TransitionType.filmBurn,
        TransitionType.softZoom,
      ];
      for (final type in newTypes) {
        expect(type.displayName, isNotEmpty);
      }
    });

    test('every TransitionType value has a unique index (Hive-safe)', () {
      final indices = TransitionType.values.map((t) => t.index).toSet();
      expect(indices.length, TransitionType.values.length);
    });

    test('every TransitionType resolves a positive-duration config', () {
      for (final type in TransitionType.values) {
        final config = TransitionConfig.forType(type);
        expect(config.type, type);
        expect(config.duration.inMilliseconds, greaterThan(0));
      }
    });

    test('total transition count reflects all milestones (11 pre-v1.5.0 + 7 new)', () {
      expect(TransitionType.values.length, 18);
    });
  });

  group('Journey (v1.5.0 featuredName for Credits)', () {
    test('defaults featuredName to empty', () {
      final journey = Journey(title: 't', tagline: 'tag', startDate: DateTime(2020), anchorDate: DateTime(2021));
      expect(journey.featuredName, isEmpty);
    });

    test('copyWith sets featuredName without disturbing partner names', () {
      final journey = Journey(
        title: 't',
        tagline: 'tag',
        startDate: DateTime(2020),
        anchorDate: DateTime(2021),
        partnerOneName: 'A',
        partnerTwoName: 'B',
      );
      final updated = journey.copyWith(featuredName: 'Child Name');
      expect(updated.featuredName, 'Child Name');
      expect(updated.partnerOneName, 'A');
      expect(updated.partnerTwoName, 'B');
    });
  });
}
