import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chapter.dart';
import '../viewmodels/chapter_viewmodel.dart';
import 'move_scene_dialog.dart';

/// Lets the Creator link a scene to a real [Chapter] record directly
/// from the Scene Editor (an alternative entry point to the Scene
/// List's "Move to Chapter" action, for when authoring a brand-new
/// scene that doesn't exist in the list yet).
class ChapterPickerField extends ConsumerWidget {
  final String? chapterId;
  final ValueChanged<String?> onChanged;

  const ChapterPickerField({super.key, required this.chapterId, required this.onChanged});

  Chapter? _findSelected(List<Chapter> chapters) {
    for (final chapter in chapters) {
      if (chapter.id == chapterId) return chapter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chapterViewModelProvider).chapters;
    final selected = _findSelected(chapters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chapter', style: AppTextStyles.label),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await MoveSceneDialog.show(context, chapters: chapters, currentChapterId: chapterId);
            onChanged(result);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surfaceBlue, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selected?.title ?? 'No chapter assigned',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.mutedWhite, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
