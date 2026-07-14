import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// A handful of the scene's own photos, floating slowly with a subtle
/// parallax drift and gentle rotation — the Family milestone's
/// signature visual. Falls back to empty (no photos to float) rather
/// than showing placeholder imagery when the scene has none.
class FloatingPhotosOverlay extends StatefulWidget {
  final List<String> photoPaths;
  const FloatingPhotosOverlay({super.key, required this.photoPaths});

  @override
  State<FloatingPhotosOverlay> createState() => _FloatingPhotosOverlayState();
}

class _FloatingPhoto {
  final String path;
  final double x;
  final double baseY;
  final double amplitude;
  final double phaseOffset;
  final double rotationRange;
  final double size;

  _FloatingPhoto({
    required this.path,
    required this.x,
    required this.baseY,
    required this.amplitude,
    required this.phaseOffset,
    required this.rotationRange,
    required this.size,
  });
}

class _FloatingPhotosOverlayState extends State<FloatingPhotosOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_FloatingPhoto> _photos;

  @override
  void initState() {
    super.initState();
    final rng = Random(2626);
    final selected = widget.photoPaths.take(5).toList();
    _photos = List.generate(selected.length, (i) {
      return _FloatingPhoto(
        path: selected[i],
        x: 0.12 + (i / max(1, selected.length - 1)) * 0.76,
        baseY: 0.2 + rng.nextDouble() * 0.55,
        amplitude: 0.03 + rng.nextDouble() * 0.04,
        phaseOffset: rng.nextDouble(),
        rotationRange: (rng.nextDouble() - 0.5) * 0.35,
        size: 78 + rng.nextDouble() * 22,
      );
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _photos.map((photo) {
                  final t = (_controller.value + photo.phaseOffset) % 1.0;
                  final y = (photo.baseY + sin(t * 2 * pi) * photo.amplitude) * constraints.maxHeight;
                  final rotation = sin(t * 2 * pi) * photo.rotationRange;

                  return Positioned(
                    left: photo.x * constraints.maxWidth - photo.size / 2,
                    top: y,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Container(
                        width: photo.size,
                        height: photo.size,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.file(
                            File(photo.path),
                            fit: BoxFit.cover,
                            cacheWidth: 220,
                            errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.surfaceBlue),
                          ),
                        ),
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
