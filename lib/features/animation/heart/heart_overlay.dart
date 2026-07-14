import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../particle_overlay.dart';

/// Floating hearts drifting gently upward — `AnimationType.heart`.
class HeartOverlay extends StatelessWidget {
  final int particleCount;
  const HeartOverlay({super.key, this.particleCount = 14});

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: particleCount,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 11),
      glyphBuilder: (context, size, opacity) => Icon(
        Icons.favorite,
        size: size,
        color: AppColors.rosePink.withValues(alpha: opacity),
      ),
    );
  }
}
