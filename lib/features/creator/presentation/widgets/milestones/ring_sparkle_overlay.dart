import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// A ring glyph with a slow pulsing glow and orbiting sparkle points —
/// the Proposal milestone's signature visual. Self-contained (not part
/// of the [AnimationType] overlay system — milestones compose their own
/// bespoke visuals independent of a scene's regular animation choice).
class RingSparkleOverlay extends StatefulWidget {
  const RingSparkleOverlay({super.key});

  @override
  State<RingSparkleOverlay> createState() => _RingSparkleOverlayState();
}

class _RingSparkleOverlayState extends State<RingSparkleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.15),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = (sin(_controller.value * 2 * pi) + 1) / 2;
            return SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70 + pulse * 10,
                    height: 70 + pulse * 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25 + pulse * 0.2),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.circle_outlined, size: 64, color: AppColors.gold),
                  ...List.generate(6, (i) {
                    final angle = (_controller.value * 2 * pi) + (i * pi / 3);
                    const radius = 60.0;
                    return Transform.translate(
                      offset: Offset(cos(angle) * radius, sin(angle) * radius),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 10,
                        color: AppColors.goldLight.withValues(alpha: 0.7),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
