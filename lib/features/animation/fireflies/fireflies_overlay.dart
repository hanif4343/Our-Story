import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../particle_overlay.dart';

/// Warm, glowing fireflies wandering upward — `AnimationType.fireflies`.
/// Distinguished from [SparkleOverlay] by a soft blurred glow (via
/// `BoxShadow`) rather than a crisp icon glyph, and a warmer gold tone.
class FirefliesOverlay extends StatelessWidget {
  final int particleCount;
  const FirefliesOverlay({super.key, this.particleCount = 10});

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: particleCount,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 14),
      glyphBuilder: (context, size, opacity) => Container(
        width: size * 0.4,
        height: size * 0.4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.goldLight.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldLight.withValues(alpha: opacity * 0.8),
              blurRadius: size * 0.8,
              spreadRadius: size * 0.25,
            ),
          ],
        ),
      ),
    );
  }
}
