import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../creator/domain/entities/scene.dart';
import '../../../creator/domain/entities/transition_config.dart';
import '../../../creator/presentation/widgets/milestones/fireworks_overlay.dart';
import '../../../animation/stars/stars_overlay.dart';
import '../../../player/presentation/widgets/background_music_player.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../../timeline/domain/entities/journey.dart';
import '../../../timeline/presentation/viewmodels/journey_viewmodel.dart';
import '../viewmodels/story_viewmodel.dart';
import '../widgets/ambient_romantic_decorations.dart';
import '../widgets/chapter_progress_bar.dart';
import '../widgets/scene_transition_builder.dart';
import '../widgets/scene_view.dart';
import '../widgets/story_progress_indicator.dart';

/// The cinematic experience itself. No editing controls, no clutter —
/// scenes autoplay and transition in sequence using each scene's own
/// authored [TransitionType]. A single tap toggles play/pause; the
/// bottom control row offers explicit Previous/Skip for discoverability
/// alongside the swipe gestures "stories"-style viewers train users to
/// expect.
class StoryPlayerScreen extends ConsumerStatefulWidget {
  const StoryPlayerScreen({super.key});

  @override
  ConsumerState<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends ConsumerState<StoryPlayerScreen> {
  bool _hasStartedPlayback = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyViewModelProvider);
    final viewModel = ref.read(storyViewModelProvider.notifier);
    final settings = ref.watch(settingsViewModelProvider);

    if (state.status == StoryPlaybackStatus.idle && state.scenes.isNotEmpty && !_hasStartedPlayback) {
      _hasStartedPlayback = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.play());
    }

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      body: switch (state.status) {
        StoryPlaybackStatus.loading => const LoadingIndicator(message: 'Setting the stage…'),
        StoryPlaybackStatus.error => Center(
            child: Text(state.errorMessage ?? 'Something went wrong.', style: const TextStyle(color: Colors.white)),
          ),
        StoryPlaybackStatus.finished => _StoryEndOverlay(
            scenes: state.scenes,
            onReplay: () {
              viewModel.restart();
              viewModel.play();
            },
          ),
        _ => state.scenes.isEmpty
            ? const _EmptyStoryMessage()
            : Stack(
                children: [
                  BackgroundMusicController(
                    musicPath: state.currentScene!.musicPath ?? settings.defaultMusicPath,
                    enabled: settings.autoPlayMusicInStoryMode && state.status == StoryPlaybackStatus.playing,
                    volume: settings.backgroundMusicVolume,
                    // The trim range only applies to a scene's own music —
                    // the app-wide default fallback track always plays in full.
                    trimStart: state.currentScene!.musicPath != null ? state.currentScene!.musicTrimStart : Duration.zero,
                    trimEnd: state.currentScene!.musicPath != null ? state.currentScene!.musicTrimEnd : null,
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => state.status == StoryPlaybackStatus.playing ? viewModel.pause() : viewModel.play(),
                      onLongPressStart: (_) => viewModel.pause(),
                      onLongPressEnd: (_) => viewModel.play(),
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity < 0) {
                          viewModel.goToNext();
                        } else if (velocity > 0) {
                          viewModel.goToPrevious();
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: TransitionConfig.forType(state.currentScene!.transitionType).duration,
                        switchInCurve: Curves.linear,
                        switchOutCurve: Curves.linear,
                        transitionBuilder: (child, animation) =>
                            SceneTransitions.build(state.currentScene!.transitionType, child, animation),
                        child: SceneView(
                          key: ValueKey(state.currentScene!.id),
                          scene: state.currentScene!,
                          onVideoEnded: () => viewModel.onVideoFinished(state.currentScene!.id),
                          isPaused: state.status == StoryPlaybackStatus.paused,
                        ),
                      ),
                    ),
                  ),
                  const IgnorePointer(child: AmbientRomanticDecorations()),
                  IgnorePointer(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            StoryProgressIndicator(total: state.scenes.length, currentIndex: state.currentIndex),
                            const SizedBox(height: 10),
                            ChapterProgressBar(
                              chapterLabel: state.currentChapterLabel,
                              chapterNumber: state.currentChapterNumber,
                              totalChapters: state.totalChapters,
                              chapterProgress: state.chapterProgress,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (state.status == StoryPlaybackStatus.paused)
                    const IgnorePointer(
                      child: Center(
                        child: Icon(Icons.pause_circle_outline, color: Colors.white70, size: 56),
                      ),
                    ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _PlaybackControls(
                          isPlaying: state.status == StoryPlaybackStatus.playing,
                          hasPrevious: state.hasPrevious,
                          hasNext: state.hasNext,
                          onPrevious: viewModel.goToPrevious,
                          onSkip: viewModel.skipScene,
                          onTogglePlay: () =>
                              state.status == StoryPlaybackStatus.playing ? viewModel.pause() : viewModel.play(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      },
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onTogglePlay;

  const _PlaybackControls({
    required this.isPlaying,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
            onPressed: hasPrevious ? onPrevious : null,
            disabledColor: Colors.white24,
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
            onPressed: onTogglePlay,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
            onPressed: hasNext ? onSkip : null,
            disabledColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _EmptyStoryMessage extends StatelessWidget {
  const _EmptyStoryMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'This story has no scenes yet. Open Creator Mode to write the first one.',
          style: TextStyle(color: AppColors.mutedWhite),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

enum _EndingStage { stats, loveYou, anniversary, credits }

/// The Story's finale (v1.5.0 Emotional Ending): a staged reveal —
/// journey statistics, then "I love you forever.", then "Happy
/// Anniversary" with fireworks/stars, then a slow cinematic Credits
/// roll — with Watch Again/Close always available so nobody is ever
/// stuck sitting through it. Stats are computed from the same [scenes]
/// list Story Mode just finished playing, plus the editable [Journey]
/// record.
class _StoryEndOverlay extends ConsumerStatefulWidget {
  final List<Scene> scenes;
  final VoidCallback onReplay;
  const _StoryEndOverlay({required this.scenes, required this.onReplay});

  @override
  ConsumerState<_StoryEndOverlay> createState() => _StoryEndOverlayState();
}

class _StoryEndOverlayState extends ConsumerState<_StoryEndOverlay> {
  _EndingStage _stage = _EndingStage.stats;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _timers.add(Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _stage = _EndingStage.loveYou);
    }));
    _timers.add(Timer(const Duration(seconds: 9), () {
      if (mounted) setState(() => _stage = _EndingStage.anniversary);
    }));
    _timers.add(Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _stage = _EndingStage.credits);
    }));
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journey = ref.watch(journeyViewModelProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.anniversaryMoodGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_stage == _EndingStage.anniversary || _stage == _EndingStage.credits) ...const [
            StarsOverlay(),
            FireworksOverlay(),
          ],
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 900),
                        child: switch (_stage) {
                          _EndingStage.stats => _StatsStage(key: const ValueKey('stats'), scenes: widget.scenes, journey: journey),
                          _EndingStage.loveYou => const _LoveYouStage(key: ValueKey('loveYou')),
                          _EndingStage.anniversary => const _AnniversaryStage(key: ValueKey('anniversary')),
                          _EndingStage.credits => _CreditsStage(key: const ValueKey('credits'), journey: journey),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: widget.onReplay,
                        child: const Text('Watch Again', style: TextStyle(color: AppColors.gold)),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('Close', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStage extends StatelessWidget {
  final List<Scene> scenes;
  final Journey? journey;
  const _StatsStage({super.key, required this.scenes, required this.journey});

  int _yearsSince(DateTime date) {
    final now = DateTime.now();
    var years = now.year - date.year;
    final hasOccurredThisYear = now.month > date.month || (now.month == date.month && now.day >= date.day);
    if (!hasOccurredThisYear) years -= 1;
    return years.clamp(0, 200);
  }

  @override
  Widget build(BuildContext context) {
    final memories = scenes.length;
    final photos = scenes.fold<int>(0, (sum, s) => sum + s.photoPaths.length);
    final videos = scenes.fold<int>(0, (sum, s) => sum + s.videoPaths.length);
    final daysTogether = journey != null ? DateTime.now().difference(journey!.startDate).inDays : 0;
    final yearsTogether = journey != null ? _yearsSince(journey!.startDate) : 0;
    final weddingYears = journey?.weddingDate != null ? _yearsSince(journey!.weddingDate!) : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Thank You', style: AppTextStyles.displayTitle, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('for reliving every moment with us', style: AppTextStyles.heroSubtitle, textAlign: TextAlign.center),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 20,
          children: [
            if (weddingYears != null) _StatTile(value: '$weddingYears', label: 'Years Married'),
            _StatTile(value: '$yearsTogether', label: 'Years Together'),
            _StatTile(value: '$daysTogether', label: 'Days Together'),
            _StatTile(value: '$memories', label: 'Memories'),
            _StatTile(value: '$photos', label: 'Photos'),
            _StatTile(value: '$videos', label: 'Videos'),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statNumber),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LoveYouStage extends StatelessWidget {
  const _LoveYouStage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'I love you forever.',
      style: AppTextStyles.displayTitle.copyWith(fontStyle: FontStyle.italic),
      textAlign: TextAlign.center,
    );
  }
}

class _AnniversaryStage extends StatelessWidget {
  const _AnniversaryStage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.favorite, color: AppColors.rosePink, size: 44),
        SizedBox(height: 18),
        Text('Happy Anniversary ❤️', style: AppTextStyles.displayTitle, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CreditsStage extends StatelessWidget {
  final Journey? journey;
  const _CreditsStage({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    final partnerOne = journey?.partnerOneName ?? '';
    final partnerTwo = journey?.partnerTwoName ?? '';
    final featured = journey?.featuredName ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Created with Love', style: AppTextStyles.sceneTitle, textAlign: TextAlign.center),
        const SizedBox(height: 22),
        if (partnerOne.isNotEmpty) Text(partnerOne, style: AppTextStyles.credits, textAlign: TextAlign.center),
        if (partnerTwo.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text('for', style: AppTextStyles.label),
          const SizedBox(height: 6),
          Text(partnerTwo, style: AppTextStyles.credits, textAlign: TextAlign.center),
        ],
        if (featured.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text('Featuring', style: AppTextStyles.label),
          const SizedBox(height: 6),
          Text(featured, style: AppTextStyles.credits, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
