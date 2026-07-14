import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../animation/domain/animation_type.dart';
import '../../../media/domain/entities/voice_note.dart';
import '../../domain/entities/background_type.dart';
import '../../domain/entities/letter.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_milestone_type.dart';
import '../../domain/entities/transition_type.dart';
import '../../domain/usecases/create_scene.dart';
import '../../domain/usecases/update_scene.dart';
import 'creator_viewmodel.dart';

enum SceneEditorSaveStatus { idle, saving, saved, autoSaving, autoSaved, error }

/// Draft state for the Create/Edit Scene screen. Fully immutable —
/// every field change produces a new [SceneEditorState] via [copyWith],
/// consistent with the rest of the app's MVVM state handling.
class SceneEditorState {
  final String? id;
  final String title;
  final String subtitle;
  final DateTime date;
  final int year;
  final String chapter;
  final String? chapterId;
  final String storyText;
  final Letter? letter;
  final List<String> photoPaths;
  final List<String> videoPaths;
  final String? voiceRecordingPath;
  final VoiceNote? voiceNote;
  final String? musicPath;
  final AnimationType animationType;
  final TransitionType transitionType;
  final BackgroundType backgroundType;
  final String? backgroundColorHex;
  final Duration displayDuration;
  final bool isFavorite;
  final List<String> tags;
  final SceneMilestoneType milestoneType;
  final SceneEditorSaveStatus saveStatus;
  final String? errorMessage;
  final DateTime? lastAutoSavedAt;

  const SceneEditorState({
    this.id,
    this.title = '',
    this.subtitle = '',
    required this.date,
    int? year,
    this.chapter = '',
    this.chapterId,
    this.storyText = '',
    this.letter,
    this.photoPaths = const [],
    this.videoPaths = const [],
    this.voiceRecordingPath,
    this.voiceNote,
    this.musicPath,
    this.animationType = AnimationType.none,
    this.transitionType = TransitionType.fade,
    this.backgroundType = BackgroundType.romanticGradient,
    this.backgroundColorHex,
    this.displayDuration = const Duration(seconds: 8),
    this.isFavorite = false,
    this.tags = const [],
    this.milestoneType = SceneMilestoneType.none,
    this.saveStatus = SceneEditorSaveStatus.idle,
    this.errorMessage,
    this.lastAutoSavedAt,
  }) : year = year ?? 0;

  bool get isEditing => id != null;

  factory SceneEditorState.fromScene(Scene scene) => SceneEditorState(
        id: scene.id,
        title: scene.title,
        subtitle: scene.subtitle,
        date: scene.date,
        year: scene.year,
        chapter: scene.chapter,
        chapterId: (scene.chapterId?.isNotEmpty ?? false) ? scene.chapterId : null,
        storyText: scene.storyText,
        letter: scene.letter,
        photoPaths: scene.photoPaths,
        videoPaths: scene.videoPaths,
        voiceRecordingPath: scene.voiceRecordingPath,
        voiceNote: scene.voiceNote,
        musicPath: scene.musicPath,
        animationType: scene.animationType,
        transitionType: scene.transitionType,
        backgroundType: scene.backgroundType,
        backgroundColorHex: scene.backgroundColorHex,
        displayDuration: scene.displayDuration,
        isFavorite: scene.isFavorite,
        tags: scene.tags,
        milestoneType: scene.milestoneType,
      );

  SceneEditorState copyWith({
    String? id,
    bool applyIdOverride = false,
    String? title,
    String? subtitle,
    DateTime? date,
    int? year,
    String? chapter,
    String? chapterId,
    bool clearChapterId = false,
    String? storyText,
    Letter? letter,
    bool clearLetter = false,
    List<String>? photoPaths,
    List<String>? videoPaths,
    String? voiceRecordingPath,
    bool clearVoiceRecordingPath = false,
    VoiceNote? voiceNote,
    bool clearVoiceNote = false,
    String? musicPath,
    bool clearMusicPath = false,
    AnimationType? animationType,
    TransitionType? transitionType,
    BackgroundType? backgroundType,
    String? backgroundColorHex,
    Duration? displayDuration,
    bool? isFavorite,
    List<String>? tags,
    SceneMilestoneType? milestoneType,
    SceneEditorSaveStatus? saveStatus,
    String? errorMessage,
    DateTime? lastAutoSavedAt,
  }) {
    return SceneEditorState(
      id: applyIdOverride ? id : this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      year: year ?? this.year,
      chapter: chapter ?? this.chapter,
      chapterId: clearChapterId ? null : (chapterId ?? this.chapterId),
      storyText: storyText ?? this.storyText,
      letter: clearLetter ? null : (letter ?? this.letter),
      photoPaths: photoPaths ?? this.photoPaths,
      videoPaths: videoPaths ?? this.videoPaths,
      voiceRecordingPath: clearVoiceRecordingPath ? null : (voiceRecordingPath ?? this.voiceRecordingPath),
      voiceNote: clearVoiceNote ? null : (voiceNote ?? this.voiceNote),
      musicPath: clearMusicPath ? null : (musicPath ?? this.musicPath),
      animationType: animationType ?? this.animationType,
      transitionType: transitionType ?? this.transitionType,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      displayDuration: displayDuration ?? this.displayDuration,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      milestoneType: milestoneType ?? this.milestoneType,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
      lastAutoSavedAt: lastAutoSavedAt ?? this.lastAutoSavedAt,
    );
  }
}

class SceneEditorViewModel extends StateNotifier<SceneEditorState> {
  final CreateScene _createScene;
  final UpdateScene _updateScene;

  Timer? _autoSaveTimer;
  static const Duration _autoSaveDebounce = Duration(milliseconds: 1200);

  SceneEditorViewModel(this._createScene, this._updateScene, SceneEditorState initial) : super(initial);

  void setTitle(String value) {
    state = state.copyWith(title: value);
    _scheduleAutoSave();
  }

  void setSubtitle(String value) {
    state = state.copyWith(subtitle: value);
    _scheduleAutoSave();
  }

  void setDate(DateTime value) {
    state = state.copyWith(date: value, year: state.year == 0 ? value.year : state.year);
    _scheduleAutoSave();
  }

  void setYear(int value) {
    state = state.copyWith(year: value);
    _scheduleAutoSave();
  }

  void setChapter(String value) {
    state = state.copyWith(chapter: value);
    _scheduleAutoSave();
  }

  /// Links this scene to a real [Chapter] record (v1.2.0). Passing
  /// `null` ungroups the scene from any chapter without touching its
  /// legacy free-text [SceneEditorState.chapter] label.
  void setChapterId(String? value) {
    state = value == null ? state.copyWith(clearChapterId: true) : state.copyWith(chapterId: value);
    _scheduleAutoSave();
  }

  void setStoryText(String value) {
    state = state.copyWith(storyText: value);
    _scheduleAutoSave();
  }

  /// Replaces the scene's [Letter] reveal content wholesale. Pass `null`
  /// to remove the letter and fall back to plain title/subtitle/story text.
  void setLetter(Letter? value) {
    state = value == null ? state.copyWith(clearLetter: true) : state.copyWith(letter: value);
    _scheduleAutoSave();
  }

  void setAnimationType(AnimationType value) {
    state = state.copyWith(animationType: value);
    _scheduleAutoSave();
  }

  void setTransitionType(TransitionType value) {
    state = state.copyWith(transitionType: value);
    _scheduleAutoSave();
  }

  void setBackgroundType(BackgroundType value) {
    state = state.copyWith(backgroundType: value);
    _scheduleAutoSave();
  }

  void setBackgroundColorHex(String value) {
    state = state.copyWith(backgroundColorHex: value);
    _scheduleAutoSave();
  }

  void setDisplayDuration(Duration value) {
    state = state.copyWith(displayDuration: value);
    _scheduleAutoSave();
  }

  void setMusicPath(String? value) {
    state = value == null ? state.copyWith(clearMusicPath: true) : state.copyWith(musicPath: value);
    _scheduleAutoSave();
  }

  void setVoiceRecordingPath(String? value) {
    state = value == null ? state.copyWith(clearVoiceRecordingPath: true) : state.copyWith(voiceRecordingPath: value);
    _scheduleAutoSave();
  }

  /// Sets the richer [VoiceNote] (path + duration + waveform) captured
  /// by [VoiceRecorderWidget]. Also keeps the legacy
  /// [SceneEditorState.voiceRecordingPath] in sync so any code still
  /// reading that plain field continues to work.
  void setVoiceNote(VoiceNote? value) {
    state = value == null
        ? state.copyWith(clearVoiceNote: true, clearVoiceRecordingPath: true)
        : state.copyWith(voiceNote: value, voiceRecordingPath: value.path);
    _scheduleAutoSave();
  }

  void addPhotoPath(String path) {
    state = state.copyWith(photoPaths: [...state.photoPaths, path]);
    _scheduleAutoSave();
  }

  void addPhotoPaths(List<String> paths) {
    if (paths.isEmpty) return;
    state = state.copyWith(photoPaths: [...state.photoPaths, ...paths]);
    _scheduleAutoSave();
  }

  void removePhotoPath(String path) {
    state = state.copyWith(photoPaths: state.photoPaths.where((p) => p != path).toList());
    _scheduleAutoSave();
  }

  /// Reorders photos in place (v1.4.0) — [oldIndex]/[newIndex] follow
  /// `ReorderableListView`'s convention (newIndex already accounts for
  /// the removed item, per its documented behaviour).
  void reorderPhotoPaths(int oldIndex, int newIndex) {
    final updated = [...state.photoPaths];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    state = state.copyWith(photoPaths: updated);
    _scheduleAutoSave();
  }

  void addVideoPath(String path) {
    state = state.copyWith(videoPaths: [...state.videoPaths, path]);
    _scheduleAutoSave();
  }

  void removeVideoPath(String path) {
    state = state.copyWith(videoPaths: state.videoPaths.where((p) => p != path).toList());
    _scheduleAutoSave();
  }

  /// Reorders videos in place (v1.4.0) — see [reorderPhotoPaths].
  void reorderVideoPaths(int oldIndex, int newIndex) {
    final updated = [...state.videoPaths];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    state = state.copyWith(videoPaths: updated);
    _scheduleAutoSave();
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
    _scheduleAutoSave();
  }

  void addTag(String rawTag) {
    final tag = rawTag.trim();
    if (tag.isEmpty || state.tags.contains(tag)) return;
    state = state.copyWith(tags: [...state.tags, tag]);
    _scheduleAutoSave();
  }

  void removeTag(String tag) {
    state = state.copyWith(tags: state.tags.where((t) => t != tag).toList());
    _scheduleAutoSave();
  }

  /// Sets the scene's themed decorative treatment (v1.3.0) — see
  /// [SceneMilestoneType].
  void setMilestoneType(SceneMilestoneType value) {
    state = state.copyWith(milestoneType: value);
    _scheduleAutoSave();
  }

  /// Debounced background save triggered by every field edit. Silent —
  /// does not surface validation errors — and only proceeds once the
  /// scene has the bare minimum (a title) to be worth persisting.
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDebounce, () {
      if (state.title.trim().isNotEmpty) {
        _persist(isAutoSave: true);
      }
    });
  }

  /// Explicit Save button — validates strictly and surfaces errors,
  /// unlike the silent [_scheduleAutoSave] path.
  Future<bool> save() async {
    _autoSaveTimer?.cancel();

    if (state.title.trim().isEmpty || state.storyText.trim().isEmpty) {
      state = state.copyWith(
        saveStatus: SceneEditorSaveStatus.error,
        errorMessage: 'Title and story text are required.',
      );
      return false;
    }
    return _persist(isAutoSave: false);
  }

  Future<bool> _persist({required bool isAutoSave}) async {
    state = state.copyWith(
      saveStatus: isAutoSave ? SceneEditorSaveStatus.autoSaving : SceneEditorSaveStatus.saving,
      errorMessage: null,
    );

    final now = DateTime.now();
    final draft = Scene(
      id: state.id ?? '',
      order: 0,
      title: state.title.trim(),
      subtitle: state.subtitle.trim(),
      date: state.date,
      year: state.year == 0 ? state.date.year : state.year,
      chapter: state.chapter.trim(),
      chapterId: state.chapterId,
      storyText: state.storyText.trim(),
      letter: state.letter,
      photoPaths: state.photoPaths,
      videoPaths: state.videoPaths,
      voiceRecordingPath: state.voiceRecordingPath,
      voiceNote: state.voiceNote,
      musicPath: state.musicPath,
      animationType: state.animationType,
      transitionType: state.transitionType,
      backgroundType: state.backgroundType,
      backgroundColorHex: state.backgroundColorHex,
      displayDuration: state.displayDuration,
      isFavorite: state.isFavorite,
      tags: state.tags,
      milestoneType: state.milestoneType,
      createdAt: now,
      updatedAt: now,
    );

    final result = state.isEditing ? await _updateScene(draft) : await _createScene(draft);

    return result.fold(
      (failure) {
        state = state.copyWith(saveStatus: SceneEditorSaveStatus.error, errorMessage: failure.message);
        return false;
      },
      (savedScene) {
        state = state.copyWith(
          id: savedScene.id,
          applyIdOverride: true,
          saveStatus: isAutoSave ? SceneEditorSaveStatus.autoSaved : SceneEditorSaveStatus.saved,
          lastAutoSavedAt: isAutoSave ? DateTime.now() : state.lastAutoSavedAt,
        );
        return true;
      },
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}

/// Family provider: pass an existing [Scene] to edit, or `null` to create.
final sceneEditorViewModelProvider =
    StateNotifierProvider.family<SceneEditorViewModel, SceneEditorState, Scene?>((ref, scene) {
  final repository = ref.watch(sceneRepositoryForEditorProvider);
  final initial = scene != null ? SceneEditorState.fromScene(scene) : SceneEditorState(date: DateTime.now());
  return SceneEditorViewModel(CreateScene(repository), UpdateScene(repository), initial);
});
