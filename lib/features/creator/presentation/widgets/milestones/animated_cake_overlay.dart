import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// A simple painted celebration cake with a gently flickering candle
/// flame — the Anniversary milestone's centerpiece motif. Painted
/// rather than an image asset, so it needs no bundled artwork and
/// scales cleanly at any size.
class AnimatedCakeOverlay extends StatefulWidget {
  const AnimatedCakeOverlay({super.key});

  @override
  State<AnimatedCakeOverlay> createState() => _AnimatedCakeOverlayState();
}

class _AnimatedCakeOverlayState extends State<AnimatedCakeOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
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
        alignment: const Alignment(0, 0.7),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final flicker = 0.85 + sin(_controller.value * 2 * pi) * 0.15;
            return CustomPaint(
              size: const Size(120, 90),
              painter: _CakePainter(flameScale: flicker),
            );
          },
        ),
      ),
    );
  }
}

class _CakePainter extends CustomPainter {
  final double flameScale;
  _CakePainter({required this.flameScale});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = AppColors.softWhite;
    final icingPaint = Paint()..color = AppColors.rosePinkLight;
    final platePaint = Paint()..color = AppColors.gold.withValues(alpha: 0.5);

    // Plate
    canvas.drawOval(Rect.fromLTWH(4, size.height - 14, size.width - 8, 10), platePaint);

    // Cake body (two tiers)
    final bottomTier = Rect.fromLTWH(10, size.height - 42, size.width - 20, 30);
    canvas.drawRRect(RRect.fromRectAndRadius(bottomTier, const Radius.circular(4)), basePaint);
    final topTier = Rect.fromLTWH(28, size.height - 60, size.width - 56, 22);
    canvas.drawRRect(RRect.fromRectAndRadius(topTier, const Radius.circular(4)), basePaint);

    // Icing drips
    canvas.drawRect(Rect.fromLTWH(10, size.height - 44, size.width - 20, 5), icingPaint);
    canvas.drawRect(Rect.fromLTWH(28, size.height - 62, size.width - 56, 4), icingPaint);

    // Candle
    final candleX = size.width / 2;
    final candleTop = size.height - 74;
    canvas.drawRect(Rect.fromLTWH(candleX - 2, candleTop, 4, 14), Paint()..color = AppColors.gold);

    // Flame
    final flamePaint = Paint()..color = const Color(0xFFFFC24D);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(candleX, candleTop - 6), width: 8 * flameScale, height: 14 * flameScale),
      flamePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CakePainter oldDelegate) => oldDelegate.flameScale != flameScale;
}
