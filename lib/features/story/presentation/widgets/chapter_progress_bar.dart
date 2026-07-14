import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shows which chapter is currently playing ("Chapter 2 of 4 — First
/// Trip") plus a slim fill bar for progress *within* that chapter,
/// distinct from [StoryProgressIndicator]'s per-scene segmented bar for
/// the whole journey.
class ChapterProgressBar extends StatelessWidget {
  final String chapterLabel;
  final int chapterNumber;
  final int totalChapters;
  final double chapterProgress;

  const ChapterProgressBar({
    super.key,
    required this.chapterLabel,
    required this.chapterNumber,
    required this.totalChapters,
    required this.chapterProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (totalChapters <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chapter $chapterNumber of $totalChapters${chapterLabel.isNotEmpty ? ' — $chapterLabel' : ''}',
          style: AppTextStyles.label.copyWith(color: AppColors.mutedWhite),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: chapterProgress.clamp(0.0, 1.0),
            minHeight: 3,
            backgroundColor: AppColors.mutedWhite.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.rosePink),
          ),
        ),
      ],
    );
  }
}
