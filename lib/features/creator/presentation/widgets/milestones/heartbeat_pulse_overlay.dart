import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// A gentle pulsing heart with a soft glow, timed like a heartbeat
/// (two quick beats, then a pause) — the Pregnancy milestone's
/// signature visual.
class HeartbeatPulseOverlay extends StatefulWidget {
  const HeartbeatPulseOverlay({super.key});

  @override
  State<HeartbeatPulseOverlay> createState() => _HeartbeatPulseOverlayState();
}

class _HeartbeatPulseOverlayState extends State<HeartbeatPulseOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // A stylized "lub-dub" curve: two quick pulses then a rest, over one cycle.
  static const List<double> _beatTimes = [0.0, 0.12, 0.22, 0.34, 1.0];
  static const List<double> _beatScales = [1.0, 1.22, 1.0, 1.15, 1.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleFor(double t) {
    for (int i = 0; i < _beatTimes.length - 1; i++) {
      if (t >= _beatTimes[i] && t <= _beatTimes[i + 1]) {
        final localT = (t - _beatTimes[i]) / (_beatTimes[i + 1] - _beatTimes[i]);
        return _beatScales[i] + (_beatScales[i + 1] - _beatScales[i]) * Curves.easeOut.transform(localT);
      }
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.25),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final scale = _scaleFor(_controller.value);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.rosePink.withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.favorite, color: AppColors.rosePink, size: 44),
              ),
            );
          },
        ),
      ),
    );
  }
}
