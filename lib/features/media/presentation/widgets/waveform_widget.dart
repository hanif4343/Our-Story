import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders a row of amplitude bars from a [VoiceNote.waveform] sample
/// list — real recorded amplitude, not a decorative placeholder. The
/// portion of the waveform already played (per [progress], 0.0–1.0) is
/// drawn in gold; the remainder in muted white, giving a scrub-style
/// "played vs remaining" read at a glance.
class WaveformWidget extends StatelessWidget {
  final List<double> samples;
  final double progress;
  final double height;

  const WaveformWidget({
    super.key,
    required this.samples,
    this.progress = 0,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No waveform available', style: TextStyle(color: AppColors.mutedWhite, fontSize: 11)),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(samples: samples, progress: progress),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double progress;

  _WaveformPainter({required this.samples, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final barCount = samples.length;
    final barWidth = size.width / (barCount * 1.6);
    final gap = barWidth * 0.6;
    final playedBars = (progress.clamp(0.0, 1.0) * barCount).round();

    final playedPaint = Paint()..color = AppColors.gold;
    final remainingPaint = Paint()..color = AppColors.mutedWhite.withValues(alpha: 0.35);

    for (int i = 0; i < barCount; i++) {
      final amplitude = samples[i].clamp(0.05, 1.0);
      final barHeight = size.height * amplitude;
      final x = i * (barWidth + gap);
      final rect = Rect.fromLTWH(x, (size.height - barHeight) / 2, barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        i < playedBars ? playedPaint : remainingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.samples != samples;
}
