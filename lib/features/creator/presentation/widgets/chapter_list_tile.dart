import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chapter.dart';

/// Single chapter row inside the reorderable Chapter List.
class ChapterListTile extends StatelessWidget {
  final Chapter chapter;
  final int sceneCount;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ChapterListTile({
    super.key,
    required this.chapter,
    required this.sceneCount,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(chapter.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.gold.withValues(alpha: 0.15),
          child: Text('${chapter.order + 1}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          chapter.title,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softWhite, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          sceneCount == 1 ? '1 scene' : '$sceneCount scenes',
          style: AppTextStyles.label,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.mutedWhite),
              onPressed: onRename,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle, color: AppColors.mutedWhite),
          ],
        ),
      ),
    );
  }
}
