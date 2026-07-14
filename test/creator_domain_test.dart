import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/features/creator/domain/entities/scene.dart';
import 'package:our_story/features/creator/presentation/viewmodels/creator_viewmodel.dart';

Scene _buildScene({
  required String id,
  required int order,
  String title = 'Untitled',
  DateTime? date,
  int? year,
  String chapter = '',
  bool isFavorite = false,
  List<String> tags = const [],
  String storyText = '',
  String subtitle = '',
}) {
  final now = DateTime(2026, 1, 1);
  return Scene(
    id: id,
    order: order,
    title: title,
    subtitle: subtitle,
    date: date ?? now,
    year: year,
    chapter: chapter,
    storyText: storyText,
    isFavorite: isFavorite,
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('Scene entity', () {
    test('defaults year to the date\'s year when not explicitly provided', () {
      final scene = _buildScene(id: '1', order: 0, date: DateTime(2017, 10, 1));
      expect(scene.year, 2017);
    });

    test('copyWith preserves fields not explicitly overridden', () {
      final scene = _buildScene(id: '1', order: 0, chapter: 'Chapter 1', tags: const ['proposal']);
      final copy = scene.copyWith(title: 'New Title');
      expect(copy.title, 'New Title');
      expect(copy.chapter, 'Chapter 1');
      expect(copy.tags, const ['proposal']);
      expect(copy.id, scene.id);
    });

    test('copyWith can toggle isFavorite independently of other fields', () {
      final scene = _buildScene(id: '1', order: 0, isFavorite: false);
      final favorited = scene.copyWith(isFavorite: true);
      expect(favorited.isFavorite, isTrue);
      expect(favorited.title, scene.title);
    });
  });

  group('CreatorState.filteredScenes', () {
    final scenes = [
      _buildScene(id: 'a', order: 0, title: 'The Day We Met', chapter: 'Chapter 1', date: DateTime(2017, 10, 1), tags: const ['meeting']),
      _buildScene(id: 'b', order: 1, title: 'First Trip', chapter: 'Chapter 2', date: DateTime(2019, 5, 3), isFavorite: true, tags: const ['travel']),
      _buildScene(id: 'c', order: 2, title: 'The Proposal', chapter: 'Chapter 2', date: DateTime(2025, 12, 24), isFavorite: true, tags: const ['proposal']),
    ];

    test('empty query and no filters returns every scene', () {
      const state = CreatorState();
      final withScenes = state.copyWith(scenes: scenes);
      expect(withScenes.filteredScenes.length, 3);
    });

    test('search query matches title case-insensitively', () {
      final state = CreatorState(scenes: scenes, searchQuery: 'trip');
      expect(state.filteredScenes.map((s) => s.id), ['b']);
    });

    test('search query matches tags', () {
      final state = CreatorState(scenes: scenes, searchQuery: 'proposal');
      expect(state.filteredScenes.map((s) => s.id), ['c']);
    });

    test('year filter narrows to the matching year', () {
      final state = CreatorState(scenes: scenes, yearFilter: 2019);
      expect(state.filteredScenes.map((s) => s.id), ['b']);
    });

    test('chapter filter narrows to the matching chapter', () {
      final state = CreatorState(scenes: scenes, chapterFilter: 'Chapter 2');
      expect(state.filteredScenes.map((s) => s.id), ['b', 'c']);
    });

    test('favoritesOnlyFilter narrows to favorites', () {
      final state = CreatorState(scenes: scenes, favoritesOnlyFilter: true);
      expect(state.filteredScenes.map((s) => s.id), ['b', 'c']);
    });

    test('availableYears is sorted and deduplicated', () {
      final state = CreatorState(scenes: scenes);
      expect(state.availableYears, [2017, 2019, 2025]);
    });

    test('availableChapters is sorted and deduplicated', () {
      final state = CreatorState(scenes: scenes);
      expect(state.availableChapters, ['Chapter 1', 'Chapter 2']);
    });

    test('canReorder is false while search or filters are active', () {
      const emptyState = CreatorState();
      expect(emptyState.canReorder, isTrue);
      expect(emptyState.copyWith(searchQuery: 'x').canReorder, isFalse);
      expect(emptyState.copyWith(yearFilter: 2020).canReorder, isFalse);
      expect(emptyState.copyWith(favoritesOnlyFilter: true).canReorder, isFalse);
    });
  });
}
