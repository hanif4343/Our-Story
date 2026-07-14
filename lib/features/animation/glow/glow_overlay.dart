import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A soft, slowly breathing radial glow centered on the scene —
/// `AnimationType.glow`. The simplest of the eight renderers by design:
/// a single `AnimatedBuilder` driving one `RadialGradient`'s opacity and
/// radius, meant for quiet, intimate scenes rather than a busy effect.
class GlowOverlay extends StatefulWidget {
  const GlowOverlay({super.key});

  @override
  State<GlowOverlay> createState() => _GlowOverlayState();
}

class _GlowOverlayState extends State<GlowOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85 + t * 0.25,
                colors: [
                  AppColors.goldLight.withValues(alpha: 0.14 + t * 0.08),
                  AppColors.goldLight.withValues(alpha: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
