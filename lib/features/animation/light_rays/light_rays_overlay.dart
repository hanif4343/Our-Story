import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Soft diagonal "god rays" of light sweeping slowly behind the scene —
/// `AnimationType.lightRays`. Painted (not built from widgets) since a
/// handful of large gradient triangles fanning from one corner is cheap
/// to redraw every frame and gives a much softer result than any
/// layered-Container approach would.
class LightRaysOverlay extends StatefulWidget {
  const LightRaysOverlay({super.key});

  @override
  State<LightRaysOverlay> createState() => _LightRaysOverlayState();
}

class _LightRaysOverlayState extends State<LightRaysOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
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
          painter: _LightRaysPainter(t: _controller.value),
        ),
      ),
    );
  }
}

class _LightRaysPainter extends CustomPainter {
  final double t;
  static const int _rayCount = 5;

  _LightRaysPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, -size.height * 0.15);
    final maxReach = size.longestSide * 1.2;

    for (int i = 0; i < _rayCount; i++) {
      final baseAngle = (i / _rayCount) * pi * 0.9 - pi * 0.45;
      final sway = sin(t * 2 * pi + i) * 0.06;
      final angle = baseAngle + sway;
      final width = 0.09 + 0.02 * sin(t * 2 * pi + i * 1.3);
      final opacity = 0.05 + 0.04 * (sin(t * 2 * pi + i * 0.7) + 1) / 2;

      final p1 = origin;
      final p2 = origin + Offset(cos(angle - width) * maxReach, sin(angle - width) * maxReach + maxReach * 0.3);
      final p3 = origin + Offset(cos(angle + width) * maxReach, sin(angle + width) * maxReach + maxReach * 0.3);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.goldLight.withValues(alpha: opacity),
            AppColors.goldLight.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromPoints(p1, p3))
        ..blendMode = BlendMode.plus;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter oldDelegate) => oldDelegate.t != t;
}
