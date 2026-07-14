import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Periodic camera-flash bursts — quick white pulses at randomized
/// intervals, like paparazzi at a wedding. Purely additive visual
/// noise on top of the scene; never intercepts touches.
class CameraFlashOverlay extends StatefulWidget {
  const CameraFlashOverlay({super.key});

  @override
  State<CameraFlashOverlay> createState() => _CameraFlashOverlayState();
}

class _CameraFlashOverlayState extends State<CameraFlashOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _scheduler;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _scheduleNextFlash();
  }

  void _scheduleNextFlash() {
    final delay = Duration(milliseconds: 1400 + _rng.nextInt(2200));
    _scheduler = Timer(delay, () {
      if (!mounted) return;
      _controller.forward(from: 0).then((_) {
        if (mounted) _controller.reverse();
      });
      _scheduleNextFlash();
    });
  }

  @override
  void dispose() {
    _scheduler?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Opacity(
          opacity: _controller.value * 0.5,
          child: const ColoredBox(color: Colors.white),
        ),
      ),
    );
  }
}
