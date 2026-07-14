import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Thin segmented progress bar across the top of Story Mode — one
/// segment per scene, like Instagram Stories, so the viewer always
/// senses pacing without any visible "app" chrome.
class StoryProgressIndicator extends StatelessWidget {
  final int total;
  final int currentIndex;

  const StoryProgressIndicator({super.key, required this.total, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index <= currentIndex;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold : AppColors.mutedWhite.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
