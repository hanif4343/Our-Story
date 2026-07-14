import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../creator/domain/entities/transition_type.dart';

/// Maps a [TransitionType] to the concrete `AnimatedSwitcher` transition
/// it should render (v1.2.0 Story Engine). `AnimatedSwitcher` calls the
/// same builder for both the incoming (animation running 0→1) and the
/// outgoing (animation running 1→0) child, which is exactly what makes
/// slide/fade/scale symmetric without any extra bookkeeping here.
///
/// `blur` and `pageCurl` are the two visually complex ones:
/// - `blur` uses a real Gaussian blur (`ImageFiltered`) that sharpens as
///   the scene settles in, combined with a fade.
/// - `pageCurl` is a stylized 3D-flip approximation (perspective +
///   Y-rotation) rather than a true bezier page curl, which would need
///   a bespoke shader/painter — documented here rather than silently
///   simplified.
class SceneTransitions {
  SceneTransitions._();

  static Widget build(TransitionType type, Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);

    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: curved, child: child);

      case TransitionType.crossDissolve:
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.02, end: 1.0).animate(curved),
            child: child,
          ),
        );

      case TransitionType.slideLeft:
        return _slide(const Offset(1, 0), curved, child);

      case TransitionType.slideRight:
        return _slide(const Offset(-1, 0), curved, child);

      case TransitionType.slideUp:
        return _slide(const Offset(0, 1), curved, child);

      case TransitionType.slideDown:
        return _slide(const Offset(0, -1), curved, child);

      case TransitionType.zoomIn:
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );

      case TransitionType.blur:
        return FadeTransition(
          opacity: curved,
          child: AnimatedBuilder(
            animation: curved,
            child: child,
            builder: (context, cachedChild) {
              final sigma = (1 - curved.value).clamp(0.0, 1.0) * 12;
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: cachedChild,
              );
            },
          ),
        );

      case TransitionType.parallax:
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.18, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );

      case TransitionType.pageCurl:
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            final angle = (1 - curved.value) * 1.4; // radians, eases to 0
            return Opacity(
              opacity: curved.value,
              child: Transform(
                alignment: Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(-angle),
                child: cachedChild,
              ),
            );
          },
        );

      case TransitionType.lightFlash:
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            // A camera-flash beat: a white wash peaks around the
            // midpoint of the transition, then fades to reveal the
            // fully-opaque new scene underneath.
            final t = curved.value;
            final flashOpacity = t < 0.5 ? (t / 0.5) : (1 - (t - 0.5) / 0.5);
            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: t, child: cachedChild),
                IgnorePointer(
                  child: Opacity(
                    opacity: flashOpacity.clamp(0.0, 1.0),
                    child: const ColoredBox(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );

      // ---- v1.5.0 Advanced Scene Transitions ----

      case TransitionType.dreamFade:
        // A softer, slower cousin of `blur`: light blur + fade + a
        // faint warm wash, evoking a half-remembered dream rather than
        // a camera racking focus.
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            final sigma = (1 - curved.value).clamp(0.0, 1.0) * 6;
            return Opacity(
              opacity: curved.value,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: cachedChild,
              ),
            );
          },
        );

      case TransitionType.romanticBlur:
        // Heavier blur than `dreamFade`, with a soft rose-tinted wash
        // that peaks mid-transition before settling.
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            final t = curved.value;
            final sigma = (1 - t).clamp(0.0, 1.0) * 14;
            final tint = (sin(t * pi)).clamp(0.0, 1.0) * 0.18;
            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: t,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: cachedChild,
                  ),
                ),
                IgnorePointer(child: Opacity(opacity: tint, child: const ColoredBox(color: AppColors.rosePink))),
              ],
            );
          },
        );

      case TransitionType.heartReveal:
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            return ClipPath(
              clipper: _HeartRevealClipper(progress: curved.value),
              child: cachedChild,
            );
          },
        );

      case TransitionType.roseBloom:
        // Scales up from a small center point with a rose-pink vignette
        // that recedes as the scene "blooms" open, like a flower.
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            final t = curved.value;
            return Opacity(
              opacity: t,
              child: Transform.scale(
                scale: 0.7 + t * 0.3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cachedChild!,
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 0.9,
                            colors: [
                              Colors.transparent,
                              AppColors.rosePinkDark.withValues(alpha: (1 - t) * 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

      case TransitionType.goldenFlash:
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            final t = curved.value;
            final flashOpacity = t < 0.5 ? (t / 0.5) : (1 - (t - 0.5) / 0.5);
            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: t, child: cachedChild),
                IgnorePointer(
                  child: Opacity(
                    opacity: flashOpacity.clamp(0.0, 1.0) * 0.85,
                    child: const ColoredBox(color: AppColors.goldLight),
                  ),
                ),
              ],
            );
          },
        );

      case TransitionType.filmBurn:
        // A warm orange/red radial "burn" sweeping in from a corner,
        // evoking old film stock burning away to reveal the next frame.
        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, cachedChild) {
            final t = curved.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: t, child: cachedChild),
                IgnorePointer(
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.6,
                          colors: [Color(0xFFB33A1E), Color(0xFF3A0E05), Colors.black],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );

      case TransitionType.softZoom:
        // A gentler, slower cousin of `zoomIn` — gives the impression
        // of a camera easing in rather than snapping to focus.
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
    }
  }

  static Widget _slide(Offset beginOffset, Animation<double> curved, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}

/// Clips to a heart shape that grows from a small point at the center
/// of the screen to fully cover it — used by
/// `SceneTransitions.build`'s `TransitionType.heartReveal` case.
class _HeartRevealClipper extends CustomClipper<Path> {
  final double progress;
  const _HeartRevealClipper({required this.progress});

  /// Traces the classic parametric heart curve (x, y roughly in
  /// [-16, 16] and [-17, 12] before scaling), centered at ([cx], [cy])
  /// and scaled by [unitSize] pixels per curve-unit.
  Path _heartPath(double cx, double cy, double unitSize) {
    final path = Path();
    const steps = 60;
    for (int i = 0; i <= steps; i++) {
      final t = (i / steps) * 2 * pi;
      final sinT = sin(t);
      final x = 16 * sinT * sinT * sinT;
      final y = -(13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t));
      final px = cx + x * unitSize;
      final py = cy + y * unitSize;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    if (progress <= 0) return Path();
    // The heart curve's half-width is ~16 curve-units; scaling so that
    // 16 * unitSize comfortably exceeds the screen's half-diagonal
    // ensures full coverage by progress == 1, regardless of aspect ratio.
    final targetHalfWidth = size.longestSide * 0.75;
    final unitSize = progress * targetHalfWidth / 16;
    return _heartPath(size.width / 2, size.height / 2, unitSize);
  }

  @override
  bool shouldReclip(covariant _HeartRevealClipper oldClipper) => oldClipper.progress != progress;
}
