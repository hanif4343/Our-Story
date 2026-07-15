import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../animation/glow/glow_overlay.dart';
import '../../../animation/heart/heart_overlay.dart';
import '../../../creator/domain/entities/scene.dart';
import '../../../creator/presentation/viewmodels/creator_viewmodel.dart';
import '../../../creator/presentation/widgets/milestones/golden_particles_overlay.dart';
import '../../../timeline/presentation/viewmodels/journey_viewmodel.dart';

/// The Premium Home Screen (v1.5.0): a luxurious landing experience —
/// animated gradient + floating hearts + golden particles + soft glow
/// behind a staggered entrance of the welcome text and quick-access
/// sections (Continue Journey, Preview Story, Anniversary Countdown,
/// Favorite Memories, Recent Scenes, Settings).
///
/// Creator Mode remains reachable via a deliberate long-press on the
/// heart emblem (unchanged since v1.0.0) — a small, tasteful "Create
/// New Story" text link is *also* offered per the v1.5.0 spec, but the
/// long-press shortcut keeps working exactly as before either way.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    // A single frame delay lets the entrance animations actually
    // animate from their "before" state instead of snapping in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  int _daysUntilNextAnniversary(DateTime anchor) {
    final now = DateTime.now();
    var next = DateTime(now.year, anchor.month, anchor.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, anchor.month, anchor.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final journey = ref.watch(journeyViewModelProvider);
    final creatorState = ref.watch(creatorViewModelProvider);
    final tagline = journey?.tagline ?? AppConstants.appTagline;
    final startDate = journey?.startDate ?? AppConstants.storyStartDate;
    final anchorDate = journey?.anchorDate ?? AppConstants.storyAnchorDate;
    final daysTogether = DateFormatter.daysSince(startDate, DateTime.now());
    final daysUntilAnniversary = _daysUntilNextAnniversary(anchorDate);

    final scenes = [...creatorState.scenes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final favorites = scenes.where((s) => s.isFavorite).take(10).toList();
    final recent = scenes.take(10).toList();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.romanticGradient)),
          const GlowOverlay(),
          const Opacity(opacity: 0.7, child: HeartOverlay(particleCount: 8)),
          const Opacity(opacity: 0.6, child: GoldenParticlesOverlay()),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                    child: Column(
                      children: [
                        _EntranceFade(
                          visible: _entered,
                          delay: Duration.zero,
                          child: GestureDetector(
                            onLongPress: () => context.push(AppRoutes.creatorLogin),
                            child: const _CoupleSilhouette(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _EntranceFade(
                          visible: _entered,
                          delay: const Duration(milliseconds: 150),
                          child: Text(tagline, style: AppTextStyles.displayTitle, textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 10),
                        _EntranceFade(
                          visible: _entered,
                          delay: const Duration(milliseconds: 250),
                          child: Text(
                            '${DateFormatter.short(startDate)} — forever · $daysTogether days of us',
                            style: AppTextStyles.heroSubtitle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _EntranceFade(
                          visible: _entered,
                          delay: const Duration(milliseconds: 350),
                          child: AppButton(
                            label: 'Continue Journey',
                            icon: Icons.play_arrow_rounded,
                            expand: true,
                            onPressed: () => context.push(AppRoutes.storyIntro),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EntranceFade(
                          visible: _entered,
                          delay: const Duration(milliseconds: 420),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.push(AppRoutes.cinematicTimeline),
                                icon: const Icon(Icons.timeline_outlined, size: 18, color: AppColors.gold),
                                label: const Text('Preview Story', style: TextStyle(color: AppColors.gold)),
                              ),
                              TextButton.icon(
                                onPressed: () => context.push(AppRoutes.creatorLogin),
                                icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.mutedWhite),
                                label: const Text('Create New Story', style: TextStyle(color: AppColors.mutedWhite)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _EntranceFade(
                    visible: _entered,
                    delay: const Duration(milliseconds: 500),
                    child: _AnniversaryCountdownCard(daysUntil: daysUntilAnniversary, anchorDate: anchorDate),
                  ),
                ),
                if (favorites.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _EntranceFade(
                      visible: _entered,
                      delay: const Duration(milliseconds: 600),
                      child: _SceneRailSection(title: 'Favorite Memories', scenes: favorites),
                    ),
                  ),
                if (recent.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _EntranceFade(
                      visible: _entered,
                      delay: const Duration(milliseconds: 700),
                      child: _SceneRailSection(title: 'Recent Scenes', scenes: recent),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 28),
                    child: Center(
                      child: IconButton(
                        onPressed: () => context.push(AppRoutes.settings),
                        icon: const Icon(Icons.settings_outlined, color: AppColors.mutedWhite),
                        tooltip: 'Settings',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered fade + rise entrance used throughout the Premium Home
/// Screen — each section animates in slightly after the one before it.
class _EntranceFade extends StatelessWidget {
  final bool visible;
  final Duration delay;
  final Widget child;
  const _EntranceFade({required this.visible, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

/// A simple, tasteful two-silhouette motif (no photo assets required) —
/// stands in for "Animated couple silhouette" from the v1.5.0 spec,
/// with a gentle continuous glow pulse.
class _CoupleSilhouette extends StatefulWidget {
  const _CoupleSilhouette();

  @override
  State<_CoupleSilhouette> createState() => _CoupleSilhouetteState();
}

class _CoupleSilhouetteState extends State<_CoupleSilhouette> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glow = 0.5 + Curves.easeInOut.transform(_controller.value) * 0.5;
        return SizedBox(
          height: 88,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.person, size: 56, color: AppColors.softWhite.withValues(alpha: 0.85)),
              Positioned(
                left: 8,
                child: Icon(Icons.person, size: 56, color: AppColors.rosePinkLight.withValues(alpha: 0.7)),
              ),
              Positioned(
                right: 8,
                child: Icon(Icons.person, size: 56, color: AppColors.rosePinkLight.withValues(alpha: 0.7)),
              ),
              Positioned(
                bottom: 4,
                child: Icon(Icons.favorite, size: 22, color: AppColors.rosePink.withValues(alpha: glow)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnniversaryCountdownCard extends StatelessWidget {
  final int daysUntil;
  final DateTime anchorDate;
  const _AnniversaryCountdownCard({required this.daysUntil, required this.anchorDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: AppColors.gold, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anniversary Countdown', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 4),
                  Text(
                    daysUntil == 0 ? "It's today! ❤" : '$daysUntil days until ${DateFormatter.monthYear(anchorDate)}',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneRailSection extends StatelessWidget {
  final String title;
  final List<Scene> scenes;
  const _SceneRailSection({required this.title, required this.scenes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(title, style: AppTextStyles.sectionLabel),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                final scene = scenes[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.scenePreview, extra: scene),
                    child: Container(
                      width: 84,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (scene.photoPaths.isNotEmpty)
                            Image.file(
                              File(scene.photoPaths.first),
                              fit: BoxFit.cover,
                              cacheWidth: 168,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.mutedWhite),
                            )
                          else
                            const Center(child: Icon(Icons.movie_creation_outlined, color: AppColors.mutedWhite)),
                          Positioned(
                            left: 6,
                            right: 6,
                            bottom: 6,
                            child: Text(
                              scene.title,
                              style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 10),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
