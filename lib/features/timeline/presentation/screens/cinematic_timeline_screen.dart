import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../animation/stars/stars_overlay.dart';
import '../../../creator/domain/entities/scene.dart';
import '../../../creator/presentation/viewmodels/creator_viewmodel.dart';
import '../../domain/services/timeline_service.dart';

/// A cinematic, camera-like journey through the timeline: chapters
/// scroll horizontally with a depth effect — the centered chapter zooms
/// in full-size while neighbors shrink and fade toward the edges, over
/// a slow-drifting starfield parallax layer — evoking a camera pushing
/// through years rather than a plain list (v1.3.0 Cinematic Experience
/// Engine). Purely a browsing/overview screen; tapping a chapter jumps
/// into Story Mode starting from that chapter's first scene.
class CinematicTimelineScreen extends ConsumerStatefulWidget {
  const CinematicTimelineScreen({super.key});

  @override
  ConsumerState<CinematicTimelineScreen> createState() => _CinematicTimelineScreenState();
}

class _CinematicTimelineScreenState extends ConsumerState<CinematicTimelineScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.72);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creatorState = ref.watch(creatorViewModelProvider);

    if (creatorState.status == CreatorLoadStatus.loading || creatorState.status == CreatorLoadStatus.idle) {
      return const Scaffold(backgroundColor: AppColors.midnightBlue, body: LoadingIndicator());
    }

    const timelineService = TimelineService();
    final orderedScenes = [...creatorState.scenes]..sort((a, b) => a.order.compareTo(b.order));
    final timeline = timelineService.build(orderedScenes);

    // Group into one card per chapter, carrying its first scene (used
    // both for the card's photo and as the Story Mode jump-in point)
    // and the chapter's year span.
    final chapters = <_ChapterCard>[];
    for (final event in timeline) {
      if (event.isFirstInChapter) {
        final chapterScenes =
            timeline.where((e) => e.chapterIndex == event.chapterIndex).map((e) => e.scene).toList();
        final years = chapterScenes.map((s) => s.year).toSet().toList()..sort();
        chapters.add(_ChapterCard(
          label: event.chapterLabel,
          years: years,
          firstScene: event.scene,
          sceneCount: chapterScenes.length,
        ));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(title: const Text('Cinematic Timeline')),
      body: chapters.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Write some scenes and group them into chapters to see your journey unfold here.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                // Slow-drifting starfield gives the scroll a sense of
                // depth — the "camera" moving through a night sky of years.
                Transform.translate(
                  offset: Offset(-_page * 18, 0),
                  child: const StarsOverlay(),
                ),
                Center(
                  child: SizedBox(
                    height: 420,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final distance = (_page - index).abs().clamp(0.0, 1.0);
                        final scale = 1.0 - distance * 0.22;
                        final opacity = 1.0 - distance * 0.55;

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: _ChapterCardView(
                              card: chapters[index],
                              onTap: () => context.push(AppRoutes.scenePreview, extra: chapters[index].firstScene),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChapterCard {
  final String label;
  final List<int> years;
  final Scene firstScene;
  final int sceneCount;

  _ChapterCard({required this.label, required this.years, required this.firstScene, required this.sceneCount});

  String get yearRange {
    if (years.isEmpty) return '';
    if (years.length == 1) return '${years.first}';
    return '${years.first} – ${years.last}';
  }
}

class _ChapterCardView extends StatelessWidget {
  final _ChapterCard card;
  final VoidCallback onTap;
  const _ChapterCardView({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: AppColors.romanticGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(card.yearRange, style: AppTextStyles.sceneDate.copyWith(fontSize: 18)),
            const SizedBox(height: 14),
            Text(card.label, style: AppTextStyles.sceneTitle, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              card.sceneCount == 1 ? '1 scene' : '${card.sceneCount} scenes',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.play_circle_outline, color: AppColors.gold, size: 32),
          ],
        ),
      ),
    );
  }
}
