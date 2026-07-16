import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../animation/butterfly/butterfly_overlay.dart';
import '../../../../animation/glow/glow_overlay.dart';
import '../../../../animation/heart/heart_overlay.dart';
import '../../../../animation/light_rays/light_rays_overlay.dart';
import '../../../../animation/rose/rose_overlay.dart';
import '../../../../animation/sparkle/sparkle_overlay.dart';
import '../../../../timeline/presentation/viewmodels/journey_viewmodel.dart';
import '../../../domain/entities/scene.dart';
import '../../../domain/entities/scene_milestone_type.dart';
import 'animated_cake_overlay.dart';
import 'camera_flash_overlay.dart';
import 'congratulations_banner.dart';
import 'countdown_overlay.dart';
import 'fireworks_overlay.dart';
import 'floating_photos_overlay.dart';
import 'golden_particles_overlay.dart';
import 'heartbeat_pulse_overlay.dart';
import 'ring_sparkle_overlay.dart';

/// Composes the themed foreground overlay + background treatment for a
/// scene's [SceneMilestoneType] (v1.3.0 Cinematic Experience Engine).
/// Every composition reuses existing overlay widgets wherever the
/// requested effect already exists (rose petals, hearts, glow, light
/// rays, butterflies, sparkles) and only introduces new bespoke widgets
/// for effects nothing else covers (ring, camera flash, heartbeat,
/// floating photos, fireworks, golden particles, cake, countdown).
///
/// `SceneMilestoneType.none` (the default) renders nothing — every
/// scene authored before v1.3.0 is completely unaffected.
class MilestonePresentation extends StatelessWidget {
  final Scene scene;
  const MilestonePresentation({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    switch (scene.milestoneType) {
      case SceneMilestoneType.none:
        return const SizedBox.shrink();

      case SceneMilestoneType.proposal:
        return const Stack(
          fit: StackFit.expand,
          children: [
            RoseOverlay(particleCount: 10),
            HeartOverlay(particleCount: 10),
            RingSparkleOverlay(),
          ],
        );

      case SceneMilestoneType.wedding:
        return const Stack(
          fit: StackFit.expand,
          children: [
            RoseOverlay(particleCount: 16),
            CameraFlashOverlay(),
            _WeddingFrame(),
          ],
        );

      case SceneMilestoneType.pregnancy:
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.rosePink.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const GlowOverlay(),
            const SparkleOverlay(particleCount: 14),
            const HeartbeatPulseOverlay(),
          ],
        );

      case SceneMilestoneType.babyBirth:
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const LightRaysOverlay(),
            const GlowOverlay(),
          ],
        );

      case SceneMilestoneType.family:
        return Stack(
          fit: StackFit.expand,
          children: [
            FloatingPhotosOverlay(photoPaths: scene.photoPaths),
            const ButterflyOverlay(),
          ],
        );

      case SceneMilestoneType.anniversary:
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [Colors.transparent, AppColors.midnightBlue.withValues(alpha: 0.45)],
                ),
              ),
            ),
            const RoseOverlay(particleCount: 10),
            const FireworksOverlay(),
            const GoldenParticlesOverlay(),
            const AnimatedCakeOverlay(),
            _AnniversaryCountdown(scene: scene),
            const CongratulationsBanner(),
          ],
        );
    }
  }
}

/// Simple decorative border framing the scene, evoking a wedding photo
/// frame — layered on top of everything else in the wedding composition.
class _WeddingFrame extends StatelessWidget {
  const _WeddingFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Reads the Journey's wedding/start date to compute "years together"
/// as of this scene's own date, then renders the animated count-up +
/// congratulations beat. Kept as the one small Riverpod-aware piece in
/// an otherwise pure-presentational composition.
class _AnniversaryCountdown extends ConsumerWidget {
  final Scene scene;
  const _AnniversaryCountdown({required this.scene});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journey = ref.watch(journeyViewModelProvider);
    final referenceDate = journey?.weddingDate ?? journey?.startDate;
    final sceneDate = scene.date;
    if (referenceDate == null || sceneDate == null) return const SizedBox.shrink();

    var years = sceneDate.year - referenceDate.year;
    final hasHadAnniversaryThisYear = sceneDate.month > referenceDate.month ||
        (sceneDate.month == referenceDate.month && sceneDate.day >= referenceDate.day);
    if (!hasHadAnniversaryThisYear) years -= 1;
    years = years.clamp(0, 200);

    return CountdownOverlay(years: years);
  }
}
