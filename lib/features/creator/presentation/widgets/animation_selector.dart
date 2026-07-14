import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../animation/domain/animation_type.dart';

/// Lets the Creator pick which decorative overlay plays during a scene.
/// The chip grid reflects every value the architecture already defines
/// in [AnimationType], even though renderers ship in a later milestone.
class AnimationSelector extends StatelessWidget {
  final AnimationType selected;
  final ValueChanged<AnimationType> onChanged;

  const AnimationSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Animation', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AnimationType.values.map((type) {
            final isSelected = type == selected;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: AppColors.rosePink,
              backgroundColor: AppColors.surfaceBlue,
              labelStyle: TextStyle(color: isSelected ? AppColors.pureWhite : AppColors.mutedWhite, fontSize: 12),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}
