import 'package:flutter/material.dart';
import 'butterfly/butterfly_overlay.dart';
import 'domain/animation_type.dart';
import 'fireflies/fireflies_overlay.dart';
import 'glow/glow_overlay.dart';
import 'heart/heart_overlay.dart';
import 'light_rays/light_rays_overlay.dart';
import 'rose/rose_overlay.dart';
import 'sparkle/sparkle_overlay.dart';
import 'stars/stars_overlay.dart';
import '../creator/domain/entities/animation_config.dart';

/// Maps an [AnimationType] to its concrete overlay widget (v1.2.0 Story
/// Engine), tuned via [AnimationConfig.forType]. Eight of the fourteen
/// defined types have real renderers — see [AnimationTypeX.hasRenderer];
/// the remainder (letter, ring, book, particles, fireworks, cloud, rain,
/// moon, golden_dust) still return an empty overlay and stay documented
/// as reserved architecture in their own
/// `features/animation/<name>/README.md`, exactly as in v1.0.0.
class AnimationOverlayFactory {
  AnimationOverlayFactory._();

  static Widget resolve(AnimationType type) {
    final config = AnimationConfig.forType(type);

    switch (type) {
      case AnimationType.heart:
        return HeartOverlay(particleCount: config.intensity);
      case AnimationType.rose:
        return RoseOverlay(particleCount: config.intensity);
      case AnimationType.butterfly:
        return const ButterflyOverlay();
      case AnimationType.sparkle:
        return SparkleOverlay(particleCount: config.intensity);
      case AnimationType.stars:
        return const StarsOverlay();
      case AnimationType.fireflies:
        return FirefliesOverlay(particleCount: config.intensity);
      case AnimationType.lightRays:
        return const LightRaysOverlay();
      case AnimationType.glow:
        return const GlowOverlay();
      case AnimationType.none:
      case AnimationType.letter:
      case AnimationType.ring:
      case AnimationType.book:
      case AnimationType.particles:
      case AnimationType.fireworks:
      case AnimationType.cloud:
      case AnimationType.rain:
      case AnimationType.moon:
      case AnimationType.goldenDust:
        return const SizedBox.shrink();
    }
  }
}
