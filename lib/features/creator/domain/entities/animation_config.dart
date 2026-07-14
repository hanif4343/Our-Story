import 'package:equatable/equatable.dart';
import '../../../animation/domain/animation_type.dart';

/// Tunable parameters for an overlay animation renderer — how many
/// particles, how fast, how strong. Not persisted per-scene (Creator
/// Mode only exposes picking the [AnimationType] itself, via
/// [AnimationSelector]); instead every type gets a sensible, curated
/// default via [AnimationConfig.forType], which is what
/// [AnimationOverlayFactory] hands to each renderer. Keeping tuning
/// centralized here — rather than each overlay widget hard-coding its
/// own numbers — is what makes it possible to rebalance "how busy do
/// hearts feel" in one place instead of six.
class AnimationConfig extends Equatable {
  final AnimationType type;

  /// Roughly "how many particles/elements" a renderer should draw.
  final int intensity;

  /// Multiplier applied to each renderer's base animation duration —
  /// 1.0 is the renderer's own default pace, <1 is faster, >1 slower.
  final double speed;

  const AnimationConfig({required this.type, this.intensity = 12, this.speed = 1.0});

  factory AnimationConfig.forType(AnimationType type) {
    switch (type) {
      case AnimationType.heart:
        return const AnimationConfig(type: AnimationType.heart, intensity: 14, speed: 1.0);
      case AnimationType.rose:
        return const AnimationConfig(type: AnimationType.rose, intensity: 12, speed: 1.0);
      case AnimationType.butterfly:
        return const AnimationConfig(type: AnimationType.butterfly, intensity: 5, speed: 1.0);
      case AnimationType.sparkle:
        return const AnimationConfig(type: AnimationType.sparkle, intensity: 20, speed: 1.1);
      case AnimationType.stars:
        return const AnimationConfig(type: AnimationType.stars, intensity: 35, speed: 1.0);
      case AnimationType.fireflies:
        return const AnimationConfig(type: AnimationType.fireflies, intensity: 10, speed: 0.9);
      case AnimationType.lightRays:
        return const AnimationConfig(type: AnimationType.lightRays, intensity: 5, speed: 0.8);
      case AnimationType.glow:
        return const AnimationConfig(type: AnimationType.glow, intensity: 1, speed: 1.0);
      default:
        return AnimationConfig(type: type, intensity: 0, speed: 1.0);
    }
  }

  @override
  List<Object?> get props => [type, intensity, speed];
}
