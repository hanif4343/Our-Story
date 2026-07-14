import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../animation/particle_overlay.dart';

/// Drifting golden particles — the Anniversary milestone's luxury
/// accent. Reuses the shared [ParticleOverlay] engine (the same one
/// backing [SparkleOverlay]/[FirefliesOverlay]) rather than a bespoke
/// particle system, per the "reuse widgets" performance goal.
class GoldenParticlesOverlay extends StatelessWidget {
  const GoldenParticlesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: 18,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 12),
      glyphBuilder: (context, size, opacity) => Icon(
        Icons.circle,
        size: size * 0.28,
        color: AppColors.gold.withValues(alpha: opacity),
      ),
    );
  }
}
