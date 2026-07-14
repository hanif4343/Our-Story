import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../animation/particle_overlay.dart';

/// A quiet, low-opacity ambient layer that plays throughout Story Mode
/// regardless of any per-scene [AnimationType] or milestone choice —
/// occasional rose petals, soft sparkles, golden dust, and a rare heart
/// burst, at low enough intensity to never compete with the photo/video
/// or text on screen (v1.5.0 Romantic Decorations).
///
/// Deliberately built from the existing shared [ParticleOverlay] engine
/// (the same one behind [HeartOverlay]/[SparkleOverlay]/etc.) rather
/// than a new particle system, keeping this cheap to run continuously
/// behind every scene.
class AmbientRomanticDecorations extends StatefulWidget {
  const AmbientRomanticDecorations({super.key});

  @override
  State<AmbientRomanticDecorations> createState() => _AmbientRomanticDecorationsState();
}

class _AmbientRomanticDecorationsState extends State<AmbientRomanticDecorations> {
  bool _showHeartBurst = false;
  Timer? _burstTimer;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _scheduleNextBurst();
  }

  void _scheduleNextBurst() {
    // A brief heart burst every 45-90 seconds — rare enough to feel like
    // a moment, not a loop.
    final delay = Duration(seconds: 45 + _rng.nextInt(45));
    _burstTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() => _showHeartBurst = true);
      Timer(const Duration(seconds: 6), () {
        if (!mounted) return;
        setState(() => _showHeartBurst = false);
        _scheduleNextBurst();
      });
    });
  }

  @override
  void dispose() {
    _burstTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Opacity(opacity: 0.35, child: _AmbientSparkles()),
          const Opacity(opacity: 0.25, child: _AmbientGoldenDust()),
          const Opacity(opacity: 0.2, child: _AmbientRosePetals()),
          if (_showHeartBurst)
            AnimatedOpacity(
              opacity: _showHeartBurst ? 0.45 : 0,
              duration: const Duration(seconds: 2),
              child: const _AmbientHeartBurst(),
            ),
        ],
      ),
    );
  }
}

/// Faint, ever-present sparkles — always faded in behind the other
/// ambient layers (see the low `Opacity` wrapping each in
/// [_AmbientRomanticDecorationsState.build]).
class _AmbientSparkles extends StatelessWidget {
  const _AmbientSparkles();

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: 8,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 16),
      glyphBuilder: (context, size, opacity) =>
          Icon(Icons.auto_awesome, size: size * 0.4, color: AppColors.gold.withValues(alpha: opacity)),
    );
  }
}

class _AmbientGoldenDust extends StatelessWidget {
  const _AmbientGoldenDust();

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: 6,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 22),
      glyphBuilder: (context, size, opacity) =>
          Icon(Icons.circle, size: size * 0.18, color: AppColors.goldLight.withValues(alpha: opacity)),
    );
  }
}

class _AmbientRosePetals extends StatelessWidget {
  const _AmbientRosePetals();

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: 4,
      drift: ParticleDrift.downward,
      loopDuration: const Duration(seconds: 20),
      glyphBuilder: (context, size, opacity) =>
          Icon(Icons.local_florist, size: size * 0.45, color: AppColors.rosePinkLight.withValues(alpha: opacity)),
    );
  }
}

class _AmbientHeartBurst extends StatelessWidget {
  const _AmbientHeartBurst();

  @override
  Widget build(BuildContext context) {
    return ParticleOverlay(
      particleCount: 10,
      drift: ParticleDrift.upward,
      loopDuration: const Duration(seconds: 6),
      glyphBuilder: (context, size, opacity) =>
          Icon(Icons.favorite, size: size * 0.55, color: AppColors.rosePink.withValues(alpha: opacity)),
    );
  }
}
