import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Bursting firework particles launching from random points along the
/// bottom of the screen — the Anniversary milestone's celebratory
/// centerpiece. Each burst is a short-lived radial particle explosion;
/// several bursts loop on staggered timers.
class FireworksOverlay extends StatefulWidget {
  const FireworksOverlay({super.key});

  @override
  State<FireworksOverlay> createState() => _FireworksOverlayState();
}

class _Burst {
  final double x;
  final double y;
  final double phaseOffset;
  final Color color;
  _Burst({required this.x, required this.y, required this.phaseOffset, required this.color});
}

class _FireworksOverlayState extends State<FireworksOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Burst> _bursts;

  @override
  void initState() {
    super.initState();
    final rng = Random(99);
    const palette = [AppColors.gold, AppColors.rosePink, AppColors.goldLight, AppColors.rosePinkLight];
    _bursts = List.generate(5, (i) {
      return _Burst(
        x: 0.15 + rng.nextDouble() * 0.7,
        y: 0.15 + rng.nextDouble() * 0.35,
        phaseOffset: i / 5,
        color: palette[i % palette.length],
      );
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
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
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _FireworksPainter(bursts: _bursts, t: _controller.value),
        ),
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final List<_Burst> bursts;
  final double t;
  static const int _particlesPerBurst = 16;

  _FireworksPainter({required this.bursts, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final localT = (t + burst.phaseOffset) % 1.0;
      // Each burst only "explodes" for the first 45% of its cycle, then rests.
      if (localT > 0.45) continue;

      final progress = localT / 0.45;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final radius = progress * 70;
      final center = Offset(burst.x * size.width, burst.y * size.height);

      final paint = Paint()..color = burst.color.withValues(alpha: opacity);
      for (int i = 0; i < _particlesPerBurst; i++) {
        final angle = (i / _particlesPerBurst) * 2 * pi;
        final point = center + Offset(cos(angle) * radius, sin(angle) * radius);
        canvas.drawCircle(point, 2.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) => oldDelegate.t != t;
}
