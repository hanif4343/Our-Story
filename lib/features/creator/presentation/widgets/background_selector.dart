import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/background_type.dart';

class BackgroundSelector extends StatelessWidget {
  final BackgroundType selected;
  final ValueChanged<BackgroundType> onChanged;

  const BackgroundSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Background', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BackgroundType.values.map((type) {
            final isSelected = type == selected;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: AppColors.rosePinkDark,
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
