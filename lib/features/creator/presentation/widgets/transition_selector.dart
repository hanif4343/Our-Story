import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/transition_type.dart';

class TransitionSelector extends StatelessWidget {
  final TransitionType selected;
  final ValueChanged<TransitionType> onChanged;

  const TransitionSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transition', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransitionType.values.map((type) {
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
