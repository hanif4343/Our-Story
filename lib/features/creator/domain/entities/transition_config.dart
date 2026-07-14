import 'package:equatable/equatable.dart';
import 'transition_type.dart';

/// Tunable parameters for a scene transition — how long it takes and
/// what easing curve it uses — resolved per [TransitionType] via
/// [TransitionConfig.forType]. [SceneTransitions.build] and
/// [StoryPlayerScreen] read the duration from here rather than a
/// hard-coded constant, so tuning "blur should be a touch slower than
/// fade" is a one-line change in this file.
class TransitionConfig extends Equatable {
  final TransitionType type;
  final Duration duration;

  const TransitionConfig({required this.type, this.duration = const Duration(milliseconds: 900)});

  factory TransitionConfig.forType(TransitionType type) {
    switch (type) {
      case TransitionType.fade:
      case TransitionType.crossDissolve:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 800));
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 650));
      case TransitionType.zoomIn:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 750));
      case TransitionType.blur:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 1000));
      case TransitionType.parallax:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 900));
      case TransitionType.pageCurl:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 950));
      case TransitionType.lightFlash:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 550));
      // v1.5.0 Advanced Scene Transitions:
      case TransitionType.dreamFade:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 1100));
      case TransitionType.romanticBlur:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 1000));
      case TransitionType.heartReveal:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 1000));
      case TransitionType.roseBloom:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 900));
      case TransitionType.goldenFlash:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 600));
      case TransitionType.filmBurn:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 850));
      case TransitionType.softZoom:
        return TransitionConfig(type: type, duration: const Duration(milliseconds: 1400));
    }
  }

  @override
  List<Object?> get props => [type, duration];
}
