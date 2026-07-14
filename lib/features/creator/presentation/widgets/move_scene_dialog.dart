import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chapter.dart';

/// Lets the Creator pick which chapter a scene belongs to (or ungroup
/// it entirely). Returns the selected chapter id, or `null` if the
/// scene should be ungrouped — distinct from returning nothing at all
/// (user cancelled), which is represented by the dialog resolving to
/// `_MoveSceneResult.cancelled`.
class MoveSceneDialog extends StatelessWidget {
  final List<Chapter> chapters;
  final String? currentChapterId;

  const MoveSceneDialog({super.key, required this.chapters, required this.currentChapterId});

  static Future<String?> show(
    BuildContext context, {
    required List<Chapter> chapters,
    required String? currentChapterId,
  }) async {
    final result = await showModalBottomSheet<_MoveSceneResult>(
      context: context,
      backgroundColor: AppColors.deepBlue,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => MoveSceneDialog(chapters: chapters, currentChapterId: currentChapterId),
    );
    if (result == null || result.cancelled) return currentChapterId;
    return result.chapterId;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Move to Chapter', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: AppColors.mutedWhite),
              title: const Text('No Chapter', style: TextStyle(color: Colors.white)),
              trailing: currentChapterId == null ? const Icon(Icons.check, color: AppColors.gold) : null,
              onTap: () => Navigator.of(context).pop(const _MoveSceneResult(chapterId: null, cancelled: false)),
            ),
            if (chapters.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'No chapters yet — create one from the Chapters screen first.',
                  style: TextStyle(color: AppColors.mutedWhite, fontSize: 12),
                ),
              ),
            ...chapters.map((chapter) => ListTile(
                  leading: const Icon(Icons.menu_book_outlined, color: AppColors.gold),
                  title: Text(chapter.title, style: const TextStyle(color: Colors.white)),
                  trailing: chapter.id == currentChapterId ? const Icon(Icons.check, color: AppColors.gold) : null,
                  onTap: () => Navigator.of(context).pop(_MoveSceneResult(chapterId: chapter.id, cancelled: false)),
                )),
          ],
        ),
      ),
    );
  }
}

class _MoveSceneResult {
  final String? chapterId;
  final bool cancelled;
  const _MoveSceneResult({required this.chapterId, required this.cancelled});
}
