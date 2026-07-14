import 'package:hive/hive.dart';
import '../../../core/constants/hive_box_names.dart';

/// Every decorative overlay animation this app supports (or reserves).
///
/// As of v1.2.0 Story Engine, eight of these have real renderers wired
/// into [AnimationOverlayFactory] — see [AnimationTypeX.hasRenderer].
/// The rest stay reserved architecture for a future milestone; see the
/// matching `features/animation/<name>/README.md` for each.
@HiveType(typeId: HiveTypeIds.animationType)
enum AnimationType {
  @HiveField(0)
  none,
  @HiveField(1)
  heart,
  @HiveField(2)
  rose,
  @HiveField(3)
  letter,
  @HiveField(4)
  ring,
  @HiveField(5)
  book,
  @HiveField(6)
  butterfly,
  @HiveField(7)
  sparkle,
  @HiveField(8)
  particles,
  @HiveField(9)
  fireworks,
  @HiveField(10)
  cloud,
  @HiveField(11)
  rain,
  @HiveField(12)
  moon,
  @HiveField(13)
  stars,
  @HiveField(14)
  goldenDust,
  @HiveField(15)
  fireflies,
  @HiveField(16)
  lightRays,
  @HiveField(17)
  glow,
}

extension AnimationTypeX on AnimationType {
  String get displayName {
    switch (this) {
      case AnimationType.none:
        return 'None';
      case AnimationType.heart:
        return 'Floating Hearts';
      case AnimationType.rose:
        return 'Falling Roses';
      case AnimationType.letter:
        return 'Love Letter';
      case AnimationType.ring:
        return 'Ring Sparkle';
      case AnimationType.book:
        return 'Story Book';
      case AnimationType.butterfly:
        return 'Butterflies';
      case AnimationType.sparkle:
        return 'Sparkles';
      case AnimationType.particles:
        return 'Particles';
      case AnimationType.fireworks:
        return 'Fireworks';
      case AnimationType.cloud:
        return 'Drifting Clouds';
      case AnimationType.rain:
        return 'Romantic Rain';
      case AnimationType.moon:
        return 'Moonlight';
      case AnimationType.stars:
        return 'Starfield';
      case AnimationType.goldenDust:
        return 'Golden Dust';
      case AnimationType.fireflies:
        return 'Fireflies';
      case AnimationType.lightRays:
        return 'Light Rays';
      case AnimationType.glow:
        return 'Glow';
    }
  }

  /// Whether this animation type has a real renderer wired into
  /// [AnimationOverlayFactory] (v1.2.0 Story Engine). The remaining
  /// values stay reserved architecture — see
  /// `features/animation/<name>/README.md`.
  bool get hasRenderer => const {
        AnimationType.heart,
        AnimationType.rose,
        AnimationType.butterfly,
        AnimationType.sparkle,
        AnimationType.stars,
        AnimationType.fireflies,
        AnimationType.lightRays,
        AnimationType.glow,
      }.contains(this);
}

/// Hand-written Hive TypeAdapter (no build_runner dependency).
class AnimationTypeAdapter extends TypeAdapter<AnimationType> {
  @override
  final int typeId = HiveTypeIds.animationType;

  @override
  AnimationType read(BinaryReader reader) {
    final index = reader.readByte();
    return AnimationType.values[index];
  }

  @override
  void write(BinaryWriter writer, AnimationType obj) {
    writer.writeByte(obj.index);
  }
}
