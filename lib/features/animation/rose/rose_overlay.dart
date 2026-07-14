import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../particle_overlay.dart';

/// Rose petals drifting gently downward — `AnimationType.rose`.
class RoseOverlay extends StatelessWidget {
  final int particleCount;
  const RoseOverlay({super.key, this.particleCount = 12});

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: particleCount,
      drift: ParticleDrift.downward,
      loopDuration: const Duration(seconds: 13),
      glyphBuilder: (context, size, opacity) => Icon(
        Icons.local_florist,
        size: size,
        color: AppColors.rosePinkLight.withValues(alpha: opacity),
      ),
    );
  }
}
