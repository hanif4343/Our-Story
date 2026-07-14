import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A static field of small stars that twinkle in place — `AnimationType.stars`.
/// Unlike the drifting particles used elsewhere, stars stay put and
/// only pulse their opacity, each on its own randomized phase, so the
/// effect reads as a night sky rather than falling/rising particles.
class StarsOverlay extends StatefulWidget {
  const StarsOverlay({super.key});

  @override
  State<StarsOverlay> createState() => _StarsOverlayState();
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double phaseOffset;
  final double twinkleSpeed;

  _Star({required this.x, required this.y, required this.size, required this.phaseOffset, required this.twinkleSpeed});
}

class _StarsOverlayState extends State<StarsOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = Random(4242);
    _stars = List.generate(35, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 1.5 + rng.nextDouble() * 2.5,
        phaseOffset: rng.nextDouble(),
        twinkleSpeed: 0.6 + rng.nextDouble() * 1.4,
      );
    });
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _StarfieldPainter(stars: _stars, t: _controller.value),
          );
        },
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarfieldPainter({required this.stars, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.softWhite;
    for (final star in stars) {
      final twinkle = (sin((t + star.phaseOffset) * star.twinkleSpeed * 2 * pi) + 1) / 2;
      paint.color = AppColors.softWhite.withValues(alpha: 0.25 + twinkle * 0.6);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => oldDelegate.t != t;
}
