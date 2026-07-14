import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/scene.dart';

/// Single scene row inside Creator Mode's reorderable timeline list.
/// Shows favorite status, chapter/tag context, and exposes duplicate,
/// favorite-toggle, and delete actions via an overflow menu (keeping
/// the row itself uncluttered).
class SceneListTile extends StatelessWidget {
  final Scene scene;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleFavorite;
  final VoidCallback onPreview;
  final VoidCallback onMove;

  const SceneListTile({
    super.key,
    required this.scene,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onToggleFavorite,
    required this.onPreview,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(scene.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.rosePink.withValues(alpha: 0.15),
          child: Text('${scene.order + 1}', style: const TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                scene.title,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softWhite, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (scene.isFavorite) ...[
              const SizedBox(width: 6),
              const Icon(Icons.favorite, size: 14, color: AppColors.rosePink),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormatter.scene(scene.date), style: AppTextStyles.label),
            if (scene.chapter.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  scene.chapter,
                  style: AppTextStyles.label.copyWith(color: AppColors.gold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                scene.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: scene.isFavorite ? AppColors.rosePink : AppColors.mutedWhite,
                size: 20,
              ),
              onPressed: onToggleFavorite,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.mutedWhite),
              color: AppColors.deepBlue,
              onSelected: (value) {
                if (value == 'preview') onPreview();
                if (value == 'move') onMove();
                if (value == 'duplicate') onDuplicate();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.softWhite),
                      SizedBox(width: 10),
                      Text('Preview', style: TextStyle(color: AppColors.softWhite)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'move',
                  child: Row(
                    children: [
                      Icon(Icons.drive_file_move_outline, size: 18, color: AppColors.softWhite),
                      SizedBox(width: 10),
                      Text('Move to Chapter', style: TextStyle(color: AppColors.softWhite)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_outlined, size: 18, color: AppColors.softWhite),
                      SizedBox(width: 10),
                      Text('Duplicate', style: TextStyle(color: AppColors.softWhite)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
            const Icon(Icons.drag_handle, color: AppColors.mutedWhite),
          ],
        ),
      ),
    );
  }
}
