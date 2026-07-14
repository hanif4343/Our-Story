import 'dart:math';
import 'package:flutter/material.dart';

/// Direction particles drift toward while the overlay loops.
enum ParticleDrift { upward, downward }

/// A single particle's randomized motion profile, generated once per
/// overlay instance and then driven purely by the animation's `t`
/// (0..1, looping) — no per-frame allocation, so this stays cheap even
/// with a few dozen particles animating continuously behind scene text.
class _Particle {
  final double startX; // 0..1 horizontal position
  final double phaseOffset; // 0..1, staggers particles across the loop
  final double swayAmplitude; // horizontal wobble, in logical pixels
  final double swayFrequency; // how many sway cycles per loop
  final double size;
  final double opacity;
  final double rotationSpeed; // full turns per loop

  _Particle({
    required this.startX,
    required this.phaseOffset,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.size,
    required this.opacity,
    required this.rotationSpeed,
  });

  factory _Particle.random(Random rng) {
    return _Particle(
      startX: rng.nextDouble(),
      phaseOffset: rng.nextDouble(),
      swayAmplitude: 10 + rng.nextDouble() * 26,
      swayFrequency: 1 + rng.nextDouble() * 2,
      size: 10 + rng.nextDouble() * 14,
      opacity: 0.35 + rng.nextDouble() * 0.5,
      rotationSpeed: rng.nextDouble() * 2 - 1,
    );
  }
}

/// Generic, low-overhead drifting-particle overlay. Renders [glyphBuilder]
/// (an icon, a small painted shape, anything) at N randomized positions
/// that continuously drift up or down the screen, swaying gently side to
/// side, fading in and out at the edges of their travel so the loop
/// never has a visible pop.
///
/// This single implementation backs [HeartOverlay], [RoseOverlay],
/// [SparkleOverlay], and [FirefliesOverlay] — each just supplies a
/// different glyph/color/count/speed, keeping every renderer both
/// reusable and cheap (one `AnimationController`, one `CustomPaint`).
class ParticleOverlay extends StatefulWidget {
  final int particleCount;
  final ParticleDrift drift;
  final Duration loopDuration;
  final Widget Function(BuildContext context, double size, double opacity) glyphBuilder;

  const ParticleOverlay({
    super.key,
    required this.particleCount,
    required this.glyphBuilder,
    this.drift = ParticleDrift.upward,
    this.loopDuration = const Duration(seconds: 10),
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.particleCount * 7919);
    _particles = List.generate(widget.particleCount, (_) => _Particle.random(rng));
    _controller = AnimationController(vsync: this, duration: widget.loopDuration)..repeat();
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
                children: _particles.map((particle) {
                  final t = (_controller.value + particle.phaseOffset) % 1.0;
                  final travel = widget.drift == ParticleDrift.upward
                      ? (1 - t) * constraints.maxHeight
                      : t * constraints.maxHeight;
                  final sway = sin(t * particle.swayFrequency * 2 * pi) * particle.swayAmplitude;
                  final fadeEdge = (t < 0.12) ? t / 0.12 : (t > 0.88 ? (1 - t) / 0.12 : 1.0);
                  final opacity = (particle.opacity * fadeEdge).clamp(0.0, 1.0);

                  return Positioned(
                    left: particle.startX * constraints.maxWidth + sway - particle.size / 2,
                    top: travel - particle.size / 2,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: t * particle.rotationSpeed * 2 * pi,
                        child: widget.glyphBuilder(context, particle.size, 1.0),
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
