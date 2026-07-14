import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A banner that scales/fades in with a slight overshoot — the
/// Anniversary milestone's celebratory closing beat, shown beneath the
/// countdown once it settles.
class CongratulationsBanner extends StatefulWidget {
  final String text;
  const CongratulationsBanner({super.key, this.text = 'Happy Anniversary'});

  @override
  State<CongratulationsBanner> createState() => _CongratulationsBannerState();
}

class _CongratulationsBannerState extends State<CongratulationsBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, 0.35),
        child: ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: _controller,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.goldShimmerGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                widget.text,
                style: AppTextStyles.button.copyWith(color: AppColors.midnightBlue, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
