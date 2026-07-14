import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/features/media/domain/entities/voice_note.dart';
import 'package:our_story/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings (v1.4.0 Music Manager)', () {
    test('defaults backgroundMusicVolume to a sensible non-zero value', () {
      const settings = AppSettings(
        hasCreatorPassword: false,
        hasCompletedFirstSetup: false,
        autoPlayMusicInStoryMode: true,
      );
      expect(settings.backgroundMusicVolume, greaterThan(0));
      expect(settings.backgroundMusicVolume, lessThanOrEqualTo(1.0));
    });

    test('AppSettings.initial() also has a valid default volume', () {
      final settings = AppSettings.initial();
      expect(settings.backgroundMusicVolume, greaterThan(0));
    });
  });

  group('VoiceNote (v1.4.0 rename support)', () {
    test('defaults to an empty label', () {
      final note = VoiceNote(path: '/tmp/x.m4a', duration: const Duration(seconds: 5), recordedAt: DateTime(2026));
      expect(note.label, isEmpty);
    });

    test('copyWith sets a label without disturbing other fields', () {
      final note = VoiceNote(
        path: '/tmp/x.m4a',
        duration: const Duration(seconds: 5),
        recordedAt: DateTime(2026),
        waveform: const [0.1, 0.5, 0.9],
      );
      final renamed = note.copyWith(label: "Dad's toast");
      expect(renamed.label, "Dad's toast");
      expect(renamed.path, note.path);
      expect(renamed.waveform, note.waveform);
      expect(renamed.duration, note.duration);
    });
  });

  group('List reorder semantics (Scene photo/video reordering)', () {
    // Mirrors the plain index-shift logic used by
    // SceneEditorViewModel.reorderPhotoPaths/reorderVideoPaths, kept
    // here as a pure-logic regression test independent of Riverpod.
    List<String> reorder(List<String> items, int oldIndex, int newIndex) {
      final updated = [...items];
      if (newIndex > oldIndex) newIndex -= 1;
      final moved = updated.removeAt(oldIndex);
      updated.insert(newIndex, moved);
      return updated;
    }

    test('moving the first item to the end', () {
      final result = reorder(['a', 'b', 'c'], 0, 3);
      expect(result, ['b', 'c', 'a']);
    });

    test('moving the last item to the start', () {
      final result = reorder(['a', 'b', 'c'], 2, 0);
      expect(result, ['c', 'a', 'b']);
    });

    test('moving an item one position forward', () {
      final result = reorder(['a', 'b', 'c', 'd'], 1, 3);
      expect(result, ['a', 'c', 'b', 'd']);
    });
  });
}
