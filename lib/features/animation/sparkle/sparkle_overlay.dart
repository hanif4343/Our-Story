import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../particle_overlay.dart';

/// Small twinkling sparkles drifting slowly upward — `AnimationType.sparkle`.
class SparkleOverlay extends StatelessWidget {
  final int particleCount;
  const SparkleOverlay({super.key, this.particleCount = 20});

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: particleCount,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 9),
      glyphBuilder: (context, size, opacity) => Icon(
        Icons.auto_awesome,
        size: size * 0.6,
        color: AppColors.gold.withValues(alpha: opacity),
      ),
    );
  }
}
