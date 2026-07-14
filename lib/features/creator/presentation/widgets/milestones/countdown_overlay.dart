import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Animates counting up from 0 to [years], then holds — "X Years
/// Together" as a celebratory reveal rather than a static number. The
/// caller computes [years] (typically from the Journey's wedding/start
/// date vs. the scene's own date) so this widget stays a pure,
/// easily-testable presentational piece.
class CountdownOverlay extends StatefulWidget {
  final int years;
  final String label;

  const CountdownOverlay({super.key, required this.years, this.label = 'Years Together'});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _countAnimation = IntTween(begin: 0, end: widget.years).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.years <= 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.55),
        child: AnimatedBuilder(
          animation: _countAnimation,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_countAnimation.value}',
                  style: AppTextStyles.heroTitle.copyWith(color: AppColors.gold, fontSize: 56),
                ),
                Text(widget.label, style: AppTextStyles.label),
              ],
            );
          },
        ),
      ),
    );
  }
}
