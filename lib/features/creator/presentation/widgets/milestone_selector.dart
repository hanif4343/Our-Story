import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/scene_milestone_type.dart';

/// Lets the Creator apply a themed cinematic treatment to a scene —
/// Proposal, Wedding, Pregnancy, Baby's Birth, Family, or Anniversary
/// (v1.3.0 Cinematic Experience Engine). `None` (the default) leaves the
/// scene exactly as it already renders.
class MilestoneSelector extends StatelessWidget {
  final SceneMilestoneType selected;
  final ValueChanged<SceneMilestoneType> onChanged;

  const MilestoneSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Milestone', style: AppTextStyles.label),
        const SizedBox(height: 6),
        Text(
          'Applies a themed cinematic treatment on top of this scene\'s existing content.',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SceneMilestoneType.values.map((type) {
            final isSelected = type == selected;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.surfaceBlue,
              labelStyle: TextStyle(color: isSelected ? AppColors.midnightBlue : AppColors.mutedWhite, fontSize: 12),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}
