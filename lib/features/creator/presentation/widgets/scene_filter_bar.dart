import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Horizontal row of filter chips: Favorites, then every distinct Year,
/// then every distinct Chapter currently used across the timeline.
/// Selecting an already-active chip clears that filter.
class SceneFilterBar extends StatelessWidget {
  final List<int> availableYears;
  final List<String> availableChapters;
  final int? selectedYear;
  final String? selectedChapter;
  final bool favoritesOnly;
  final ValueChanged<int?> onYearSelected;
  final ValueChanged<String?> onChapterSelected;
  final ValueChanged<bool> onFavoritesToggled;

  const SceneFilterBar({
    super.key,
    required this.availableYears,
    required this.availableChapters,
    required this.selectedYear,
    required this.selectedChapter,
    required this.favoritesOnly,
    required this.onYearSelected,
    required this.onChapterSelected,
    required this.onFavoritesToggled,
  });

  @override
  Widget build(BuildContext context) {
    if (availableYears.isEmpty && availableChapters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Favorites'),
            avatar: Icon(
              Icons.favorite,
              size: 16,
              color: favoritesOnly ? AppColors.pureWhite : AppColors.rosePink,
            ),
            selected: favoritesOnly,
            onSelected: onFavoritesToggled,
            selectedColor: AppColors.rosePink,
            backgroundColor: AppColors.surfaceBlue,
            labelStyle: TextStyle(
              color: favoritesOnly ? AppColors.pureWhite : AppColors.mutedWhite,
              fontSize: 12,
            ),
            side: BorderSide.none,
          ),
          const SizedBox(width: 8),
          ...availableYears.map((year) {
            final isSelected = year == selectedYear;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(year.toString()),
                selected: isSelected,
                onSelected: (_) => onYearSelected(isSelected ? null : year),
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.surfaceBlue,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.midnightBlue : AppColors.mutedWhite,
                  fontSize: 12,
                ),
                side: BorderSide.none,
              ),
            );
          }),
          ...availableChapters.map((chapter) {
            final isSelected = chapter == selectedChapter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(chapter, overflow: TextOverflow.ellipsis),
                selected: isSelected,
                onSelected: (_) => onChapterSelected(isSelected ? null : chapter),
                selectedColor: AppColors.rosePinkDark,
                backgroundColor: AppColors.surfaceBlue,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.pureWhite : AppColors.mutedWhite,
                  fontSize: 12,
                ),
                side: BorderSide.none,
              ),
            );
          }),
        ],
      ),
    );
  }
}
