import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../creator/domain/entities/scene.dart';
import '../../../timeline/domain/entities/timeline_event.dart';
import '../../../timeline/domain/services/timeline_service.dart';
import '../../domain/usecases/get_story_timeline.dart';

enum StoryPlaybackStatus { idle, loading, playing, paused, finished, error }

class StoryState {
  final StoryPlaybackStatus status;
  final List<Scene> scenes;
  final List<TimelineEvent> timeline;
  final int currentIndex;
  final String? errorMessage;

  const StoryState({
    this.status = StoryPlaybackStatus.idle,
    this.scenes = const [],
    this.timeline = const [],
    this.currentIndex = 0,
    this.errorMessage,
  });

  Scene? get currentScene => scenes.isEmpty ? null : scenes[currentIndex];
  TimelineEvent? get currentEvent => timeline.isEmpty ? null : timeline[currentIndex];
  bool get hasNext => currentIndex < scenes.length - 1;
  bool get hasPrevious => currentIndex > 0;

  /// Overall progress across the entire journey (0..1).
  double get progress => scenes.isEmpty ? 0 : (currentIndex + 1) / scenes.length;

  /// Progress within the *current chapter* only (0..1) — resets each
  /// time playback crosses into a new chapter.
  double get chapterProgress {
    final event = currentEvent;
    if (event == null || event.chapterSceneCount == 0) return 0;
    return (event.sceneIndexInChapter + 1) / event.chapterSceneCount;
  }

  int get totalChapters => timeline.isEmpty ? 0 : timeline.map((e) => e.chapterIndex).toSet().length;
  int get currentChapterNumber => (currentEvent?.chapterIndex ?? 0) + 1;
  String get currentChapterLabel => currentEvent?.chapterLabel ?? '';

  StoryState copyWith({
    StoryPlaybackStatus? status,
    List<Scene>? scenes,
    List<TimelineEvent>? timeline,
    int? currentIndex,
    String? errorMessage,
  }) {
    return StoryState(
      status: status ?? this.status,
      scenes: scenes ?? this.scenes,
      timeline: timeline ?? this.timeline,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the cinematic autoplay engine: loads the timeline once, then
/// advances scene-by-scene on a timer sized to each scene's
/// `displayDuration`, exactly like a movie player. Story Mode screens
/// only render [StoryState.currentScene] — all sequencing logic lives
/// here, not in the widget tree.
///
/// v1.2.0 Story Engine: also computes the chapter-grouped
/// [TimelineEvent] projection via [TimelineService], powering the
/// dual total/chapter progress bars in [StoryPlayerScreen].
class StoryViewModel extends StateNotifier<StoryState> {
  final GetStoryTimeline _getStoryTimeline;
  final TimelineService _timelineService;
  Timer? _autoAdvanceTimer;

  StoryViewModel(this._getStoryTimeline, this._timelineService) : super(const StoryState()) {
    _loadTimeline();
  }

  void _loadTimeline() {
    state = state.copyWith(status: StoryPlaybackStatus.loading);
    final result = _getStoryTimeline();
    result.fold(
      (failure) => state = state.copyWith(status: StoryPlaybackStatus.error, errorMessage: failure.message),
      (scenes) => state = state.copyWith(
        status: StoryPlaybackStatus.idle,
        scenes: scenes,
        timeline: _timelineService.build(scenes),
        currentIndex: 0,
      ),
    );
  }

  void play() {
    if (state.scenes.isEmpty) return;
    state = state.copyWith(status: StoryPlaybackStatus.playing);
    _scheduleNext();
  }

  void pause() {
    _autoAdvanceTimer?.cancel();
    state = state.copyWith(status: StoryPlaybackStatus.paused);
  }

  void _scheduleNext() {
    _autoAdvanceTimer?.cancel();
    final scene = state.currentScene;
    if (scene == null) return;
    _autoAdvanceTimer = Timer(scene.displayDuration, _advance);
  }

  void _advance() {
    if (!state.hasNext) {
      state = state.copyWith(status: StoryPlaybackStatus.finished);
      return;
    }
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    if (state.status == StoryPlaybackStatus.playing) _scheduleNext();
  }

  /// Advances immediately to the next scene, skipping the remainder of
  /// the current scene's display duration — same outcome as [goToNext],
  /// named separately so the Story Player's explicit "skip" control
  /// reads clearly at the call site.
  void skipScene() => goToNext();

  void goToNext() {
    if (!state.hasNext) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    if (state.status == StoryPlaybackStatus.playing) _scheduleNext();
  }

  void goToPrevious() {
    if (!state.hasPrevious) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
    if (state.status == StoryPlaybackStatus.playing) _scheduleNext();
  }

  void restart() {
    state = state.copyWith(currentIndex: 0, status: StoryPlaybackStatus.idle);
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }
}

final storyViewModelProvider = StateNotifierProvider.autoDispose<StoryViewModel, StoryState>((ref) {
  return StoryViewModel(GetStoryTimeline(ref.watch(storyRepositoryProvider)), const TimelineService());
});
