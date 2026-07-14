import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/usecases/delete_scene.dart';
import '../../domain/usecases/duplicate_scene.dart';
import '../../domain/usecases/get_all_scenes.dart';
import '../../domain/usecases/reorder_scenes.dart';
import '../../domain/usecases/update_scene.dart';

enum CreatorLoadStatus { idle, loading, loaded, error }

class CreatorState {
  final CreatorLoadStatus status;
  final List<Scene> scenes;
  final String? errorMessage;
  final String searchQuery;
  final int? yearFilter;
  final String? chapterFilter;
  final bool favoritesOnlyFilter;

  const CreatorState({
    this.status = CreatorLoadStatus.idle,
    this.scenes = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.yearFilter,
    this.chapterFilter,
    this.favoritesOnlyFilter = false,
  });

  /// Scenes narrowed by the active search query + year/chapter/favorite
  /// filters. Recomputed on every access rather than cached — the
  /// timeline is small enough (a personal love story, not a database)
  /// that this stays effectively free.
  List<Scene> get filteredScenes {
    final query = searchQuery.trim().toLowerCase();

    return scenes.where((scene) {
      final matchesQuery = query.isEmpty ||
          scene.title.toLowerCase().contains(query) ||
          scene.subtitle.toLowerCase().contains(query) ||
          scene.storyText.toLowerCase().contains(query) ||
          scene.chapter.toLowerCase().contains(query) ||
          scene.tags.any((tag) => tag.toLowerCase().contains(query));

      final matchesYear = yearFilter == null || scene.year == yearFilter;
      final matchesChapter = chapterFilter == null || chapterFilter!.isEmpty || scene.chapter == chapterFilter;
      final matchesFavorite = !favoritesOnlyFilter || scene.isFavorite;

      return matchesQuery && matchesYear && matchesChapter && matchesFavorite;
    }).toList();
  }

  /// Every distinct year currently used across scenes, sorted ascending —
  /// powers the "Filter by Year" chip row.
  List<int> get availableYears {
    final years = scenes.map((s) => s.year).toSet().toList();
    years.sort();
    return years;
  }

  /// Every distinct non-empty chapter label currently in use — powers
  /// the "Filter by Chapter" chip row.
  List<String> get availableChapters {
    final chapters = scenes.map((s) => s.chapter).where((c) => c.trim().isNotEmpty).toSet().toList();
    chapters.sort();
    return chapters;
  }

  bool get hasActiveFilters => yearFilter != null || (chapterFilter?.isNotEmpty ?? false) || favoritesOnlyFilter;

  /// Reordering only makes unambiguous sense against the *full* timeline.
  /// While a search or filter narrows what's visible, the UI disables
  /// drag-to-reorder rather than guess how a partial view maps back onto
  /// full scene order.
  bool get canReorder => searchQuery.trim().isEmpty && !hasActiveFilters;

  CreatorState copyWith({
    CreatorLoadStatus? status,
    List<Scene>? scenes,
    String? errorMessage,
    String? searchQuery,
    int? yearFilter,
    bool clearYearFilter = false,
    String? chapterFilter,
    bool clearChapterFilter = false,
    bool? favoritesOnlyFilter,
  }) {
    return CreatorState(
      status: status ?? this.status,
      scenes: scenes ?? this.scenes,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      yearFilter: clearYearFilter ? null : (yearFilter ?? this.yearFilter),
      chapterFilter: clearChapterFilter ? null : (chapterFilter ?? this.chapterFilter),
      favoritesOnlyFilter: favoritesOnlyFilter ?? this.favoritesOnlyFilter,
    );
  }
}

/// Drives Creator Mode's Scene List: loading, search, filtering, delete,
/// duplicate, favorite-toggle, and reorder. Scene creation/editing state
/// lives separately in [SceneEditorViewModel].
class CreatorViewModel extends StateNotifier<CreatorState> {
  final GetAllScenes _getAllScenes;
  final DeleteScene _deleteScene;
  final ReorderScenes _reorderScenes;
  final DuplicateScene _duplicateScene;
  final UpdateScene _updateScene;

  CreatorViewModel(
    this._getAllScenes,
    this._deleteScene,
    this._reorderScenes,
    this._duplicateScene,
    this._updateScene,
  ) : super(const CreatorState()) {
    loadScenes();
  }

  void loadScenes() {
    state = state.copyWith(status: CreatorLoadStatus.loading);
    final result = _getAllScenes();
    result.fold(
      (failure) => state = state.copyWith(status: CreatorLoadStatus.error, errorMessage: failure.message),
      (scenes) => state = state.copyWith(status: CreatorLoadStatus.loaded, scenes: scenes),
    );
  }

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);

  void setYearFilter(int? year) {
    state = year == null ? state.copyWith(clearYearFilter: true) : state.copyWith(yearFilter: year);
  }

  void setChapterFilter(String? chapter) {
    state = (chapter == null || chapter.isEmpty)
        ? state.copyWith(clearChapterFilter: true)
        : state.copyWith(chapterFilter: chapter);
  }

  void setFavoritesOnlyFilter(bool enabled) => state = state.copyWith(favoritesOnlyFilter: enabled);

  void clearAllFilters() {
    state = state.copyWith(
      clearYearFilter: true,
      clearChapterFilter: true,
      favoritesOnlyFilter: false,
      searchQuery: '',
    );
  }

  Future<bool> deleteScene(String sceneId) async {
    final result = await _deleteScene(sceneId);
    return result.fold(
      (failure) {
        state = state.copyWith(status: CreatorLoadStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        loadScenes();
        return true;
      },
    );
  }

  Future<bool> duplicateScene(String sceneId) async {
    final result = await _duplicateScene(sceneId);
    return result.fold(
      (failure) {
        state = state.copyWith(status: CreatorLoadStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        loadScenes();
        return true;
      },
    );
  }

  Future<bool> toggleFavorite(Scene scene) async {
    final result = await _updateScene(scene.copyWith(isFavorite: !scene.isFavorite));
    return result.fold(
      (failure) {
        state = state.copyWith(status: CreatorLoadStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        loadScenes();
        return true;
      },
    );
  }

  /// [oldIndex]/[newIndex] refer to positions within the full, unfiltered
  /// timeline (`state.scenes`). The Scene List screen only allows
  /// dragging when [CreatorState.canReorder] is true, i.e. no search or
  /// filter is currently narrowing the view.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final updated = [...state.scenes];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);

    // Optimistic UI update.
    state = state.copyWith(scenes: updated);

    final orderedIds = updated.map((s) => s.id).toList();
    final result = await _reorderScenes(orderedIds);
    result.fold(
      (failure) => state = state.copyWith(status: CreatorLoadStatus.error, errorMessage: failure.message),
      (_) => loadScenes(),
    );
  }
}

final creatorViewModelProvider = StateNotifierProvider<CreatorViewModel, CreatorState>((ref) {
  final repository = ref.watch(sceneRepositoryProvider);
  return CreatorViewModel(
    GetAllScenes(repository),
    DeleteScene(repository),
    ReorderScenes(repository),
    DuplicateScene(repository),
    UpdateScene(repository),
  );
});

final sceneRepositoryForEditorProvider = Provider<SceneRepository>((ref) => ref.watch(sceneRepositoryProvider));
