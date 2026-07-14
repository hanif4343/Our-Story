import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A handful of butterflies fluttering along gentle S-curve flight
/// paths across the screen — `AnimationType.butterfly`. Distinct from
/// the drifting particle system: each butterfly follows its own looping
/// sine-based path (not a straight drift) and its wings visually "flap"
/// via a fast secondary rotation, which reads much more like flight
/// than a falling/rising particle would.
class ButterflyOverlay extends StatefulWidget {
  const ButterflyOverlay({super.key});

  @override
  State<ButterflyOverlay> createState() => _ButterflyOverlayState();
}

class _ButterflyPath {
  final double baseY; // 0..1
  final double amplitude; // vertical wander, in fraction of height
  final double speed; // horizontal loops per animation cycle
  final double phaseOffset;
  final double flapSpeed;
  final Color color;

  _ButterflyPath({
    required this.baseY,
    required this.amplitude,
    required this.speed,
    required this.phaseOffset,
    required this.flapSpeed,
    required this.color,
  });
}

class _ButterflyOverlayState extends State<ButterflyOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ButterflyPath> _butterflies;

  @override
  void initState() {
    super.initState();
    final rng = Random(1917);
    final palette = [AppColors.rosePink, AppColors.gold, AppColors.rosePinkLight];
    _butterflies = List.generate(5, (i) {
      return _ButterflyPath(
        baseY: 0.15 + rng.nextDouble() * 0.6,
        amplitude: 0.05 + rng.nextDouble() * 0.08,
        speed: 0.7 + rng.nextDouble() * 0.6,
        phaseOffset: rng.nextDouble(),
        flapSpeed: 6 + rng.nextDouble() * 4,
        color: palette[i % palette.length],
      );
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
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
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _butterflies.map((b) {
                  final t = (_controller.value + b.phaseOffset) % 1.0;
                  final x = t * constraints.maxWidth;
                  final y = (b.baseY + sin(t * b.speed * 2 * pi) * b.amplitude) * constraints.maxHeight;
                  final flap = sin(t * b.flapSpeed * 2 * pi) * 0.5 + 0.5;
                  final fadeEdge = (t < 0.06) ? t / 0.06 : (t > 0.94 ? (1 - t) / 0.06 : 1.0);

                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: (0.75 * fadeEdge).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scaleX: 0.6 + flap * 0.4,
                        child: Icon(Icons.flutter_dash, size: 22, color: b.color),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
