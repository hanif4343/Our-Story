import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/chapter.dart';
import '../viewmodels/chapter_viewmodel.dart';
import '../viewmodels/creator_viewmodel.dart';
import '../widgets/chapter_editor_dialog.dart';
import '../widgets/chapter_list_tile.dart';

/// Chapter management: create, rename, delete, and drag-to-reorder
/// chapters. Scene counts per chapter come from the same
/// [CreatorViewModel] the Scene List uses, so both screens always agree.
class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key});

  Future<void> _createChapter(BuildContext context, WidgetRef ref) async {
    final result = await ChapterEditorDialog.show(context, confirmLabel: 'Create');
    if (result == null || result.title.isEmpty) return;
    await ref.read(chapterViewModelProvider.notifier).createChapter(result.title, subtitle: result.subtitle);
  }

  Future<void> _renameChapter(BuildContext context, WidgetRef ref, Chapter chapter) async {
    final result = await ChapterEditorDialog.show(
      context,
      initialTitle: chapter.title,
      initialSubtitle: chapter.subtitle,
      confirmLabel: 'Save',
    );
    if (result == null || result.title.isEmpty) return;
    await ref
        .read(chapterViewModelProvider.notifier)
        .renameChapter(chapter, result.title, newSubtitle: result.subtitle);
  }

  Future<void> _deleteChapter(BuildContext context, WidgetRef ref, Chapter chapter) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete "${chapter.title}"?',
      message: 'Scenes in this chapter are kept — they just become ungrouped.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed) await ref.read(chapterViewModelProvider.notifier).deleteChapter(chapter.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterState = ref.watch(chapterViewModelProvider);
    final chapterViewModel = ref.read(chapterViewModelProvider.notifier);
    final creatorState = ref.watch(creatorViewModelProvider);

    int sceneCountFor(String chapterId) => creatorState.scenes.where((s) => s.chapterId == chapterId).length;

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(title: const Text('Chapters')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createChapter(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Chapter'),
      ),
      body: switch (chapterState.status) {
        ChapterLoadStatus.loading || ChapterLoadStatus.idle => const LoadingIndicator(message: 'Loading chapters…'),
        ChapterLoadStatus.error => Center(
            child: Text(chapterState.errorMessage ?? 'Something went wrong.', style: AppTextStyles.bodyMedium),
          ),
        ChapterLoadStatus.loaded => chapterState.chapters.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No chapters yet. Chapters group scenes into parts of your story '
                    '— tap "New Chapter" to create your first one.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 100),
                itemCount: chapterState.chapters.length,
                onReorder: chapterViewModel.reorder,
                itemBuilder: (context, index) {
                  final chapter = chapterState.chapters[index];
                  return ChapterListTile(
                    key: ValueKey(chapter.id),
                    chapter: chapter,
                    sceneCount: sceneCountFor(chapter.id),
                    onRename: () => _renameChapter(context, ref, chapter),
                    onDelete: () => _deleteChapter(context, ref, chapter),
                  );
                },
              ),
      },
    );
  }
}
