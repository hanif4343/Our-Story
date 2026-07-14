import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/scene.dart';
import '../../domain/usecases/create_chapter.dart';
import '../../domain/usecases/delete_chapter.dart';
import '../../domain/usecases/get_all_chapters.dart';
import '../../domain/usecases/move_scene_to_chapter.dart';
import '../../domain/usecases/rename_chapter.dart';
import '../../domain/usecases/reorder_chapters.dart';

enum ChapterLoadStatus { idle, loading, loaded, error }

class ChapterState {
  final ChapterLoadStatus status;
  final List<Chapter> chapters;
  final String? errorMessage;

  const ChapterState({
    this.status = ChapterLoadStatus.idle,
    this.chapters = const [],
    this.errorMessage,
  });

  ChapterState copyWith({ChapterLoadStatus? status, List<Chapter>? chapters, String? errorMessage}) {
    return ChapterState(
      status: status ?? this.status,
      chapters: chapters ?? this.chapters,
      errorMessage: errorMessage,
    );
  }
}

/// Drives Chapter management: create, rename, delete, reorder, and
/// moving a scene between chapters. Mirrors [CreatorViewModel]'s shape
/// for scenes.
class ChapterViewModel extends StateNotifier<ChapterState> {
  final GetAllChapters _getAllChapters;
  final CreateChapter _createChapter;
  final RenameChapter _renameChapter;
  final DeleteChapter _deleteChapter;
  final ReorderChapters _reorderChapters;
  final MoveSceneToChapter _moveSceneToChapter;

  ChapterViewModel(
    this._getAllChapters,
    this._createChapter,
    this._renameChapter,
    this._deleteChapter,
    this._reorderChapters,
    this._moveSceneToChapter,
  ) : super(const ChapterState()) {
    loadChapters();
  }

  void loadChapters() {
    state = state.copyWith(status: ChapterLoadStatus.loading);
    final result = _getAllChapters();
    result.fold(
      (failure) => state = state.copyWith(status: ChapterLoadStatus.error, errorMessage: failure.message),
      (chapters) => state = state.copyWith(status: ChapterLoadStatus.loaded, chapters: chapters),
    );
  }

  Future<bool> createChapter(String title, {String subtitle = ''}) async {
    final result = await _createChapter(title: title, subtitle: subtitle);
    return result.fold(
      (failure) {
        state = state.copyWith(status: ChapterLoadStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        loadChapters();
        return true;
      },
    );
  }

  Future<bool> renameChapter(Chapter chapter, String newTitle, {String? newSubtitle}) async {
    final result = await _renameChapter(chapter, title: newTitle, subtitle: newSubtitle);
    return result.fold(
      (failure) {
        state = state.copyWith(status: ChapterLoadStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        loadChapters();
        return true;
      },
    );
  }

  Future<bool> deleteChapter(String chapterId) async {
    final result = await _deleteChapter(chapterId);
    return result.fold(
      (failure) {
        state = state.copyWith(status: ChapterLoadStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        loadChapters();
        return true;
      },
    );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final updated = [...state.chapters];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);

    state = state.copyWith(chapters: updated);

    final orderedIds = updated.map((c) => c.id).toList();
    final result = await _reorderChapters(orderedIds);
    result.fold(
      (failure) => state = state.copyWith(status: ChapterLoadStatus.error, errorMessage: failure.message),
      (_) => loadChapters(),
    );
  }

  Future<Scene?> moveSceneToChapter(Scene scene, String? chapterId) async {
    final result = await _moveSceneToChapter(scene, chapterId);
    return result.fold(
      (failure) {
        state = state.copyWith(status: ChapterLoadStatus.error, errorMessage: failure.message);
        return null;
      },
      (updatedScene) => updatedScene,
    );
  }
}

final chapterViewModelProvider = StateNotifierProvider<ChapterViewModel, ChapterState>((ref) {
  final chapterRepository = ref.watch(chapterRepositoryProvider);
  final sceneRepository = ref.watch(sceneRepositoryProvider);
  return ChapterViewModel(
    GetAllChapters(chapterRepository),
    CreateChapter(chapterRepository),
    RenameChapter(chapterRepository),
    DeleteChapter(chapterRepository, sceneRepository),
    ReorderChapters(chapterRepository),
    MoveSceneToChapter(sceneRepository, chapterRepository),
  );
});
