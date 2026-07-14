import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/scene.dart';
import '../viewmodels/chapter_viewmodel.dart';
import '../viewmodels/creator_viewmodel.dart';
import '../widgets/move_scene_dialog.dart';
import '../widgets/scene_filter_bar.dart';
import '../widgets/scene_list_tile.dart';
import '../widgets/scene_search_bar.dart';

/// Creator Mode's Scene List: search, filter (year/chapter/favorites),
/// reorderable timeline, and per-scene create/edit/duplicate/delete/
/// favorite actions, plus a "Preview as Story" shortcut.
class CreatorHomeScreen extends ConsumerWidget {
  const CreatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creatorViewModelProvider);
    final viewModel = ref.read(creatorViewModelProvider.notifier);
    final visibleScenes = state.filteredScenes;

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(
        title: const Text('Scene List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Chapters',
            onPressed: () => context.push(AppRoutes.chapterList),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            tooltip: 'Preview as Story',
            onPressed: state.scenes.isEmpty ? null : () => context.push(AppRoutes.storyIntro),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.sceneCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Scene'),
      ),
      body: switch (state.status) {
        CreatorLoadStatus.loading || CreatorLoadStatus.idle => const LoadingIndicator(message: 'Loading your story…'),
        CreatorLoadStatus.error => Center(
            child: Text(state.errorMessage ?? 'Something went wrong.', style: AppTextStyles.bodyMedium),
          ),
        CreatorLoadStatus.loaded => state.scenes.isEmpty
            ? const _EmptyTimelineMessage()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SceneSearchBar(value: state.searchQuery, onChanged: viewModel.setSearchQuery),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SceneFilterBar(
                      availableYears: state.availableYears,
                      availableChapters: state.availableChapters,
                      selectedYear: state.yearFilter,
                      selectedChapter: state.chapterFilter,
                      favoritesOnly: state.favoritesOnlyFilter,
                      onYearSelected: viewModel.setYearFilter,
                      onChapterSelected: viewModel.setChapterFilter,
                      onFavoritesToggled: viewModel.setFavoritesOnlyFilter,
                    ),
                  ),
                  if (!state.canReorder)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.mutedWhite),
                          const SizedBox(width: 6),
                          Text('Clear search/filters to drag-reorder scenes.', style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: visibleScenes.isEmpty
                        ? const _NoResultsMessage()
                        : state.canReorder
                            ? ReorderableListView.builder(
                                padding: const EdgeInsets.only(top: 8, bottom: 100),
                                itemCount: visibleScenes.length,
                                onReorder: viewModel.reorder,
                                itemBuilder: (context, index) => _buildTile(context, ref, viewModel, visibleScenes[index]),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 8, bottom: 100),
                                itemCount: visibleScenes.length,
                                itemBuilder: (context, index) => _buildTile(context, ref, viewModel, visibleScenes[index]),
                              ),
                  ),
                ],
              ),
      },
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, CreatorViewModel viewModel, Scene scene) {
    return SceneListTile(
      key: ValueKey(scene.id),
      scene: scene,
      onTap: () => context.push(AppRoutes.sceneEdit, extra: scene),
      onToggleFavorite: () => viewModel.toggleFavorite(scene),
      onPreview: () => context.push(AppRoutes.scenePreview, extra: scene),
      onMove: () async {
        final chapters = ref.read(chapterViewModelProvider).chapters;
        final chapterId = await MoveSceneDialog.show(
          context,
          chapters: chapters,
          currentChapterId: scene.chapterId,
        );
        if (chapterId != scene.chapterId) {
          await ref.read(chapterViewModelProvider.notifier).moveSceneToChapter(scene, chapterId);
          viewModel.loadScenes();
        }
      },
      onDuplicate: () async {
        final success = await viewModel.duplicateScene(scene.id);
        if (context.mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${scene.title}" duplicated.')),
          );
        }
      },
      onDelete: () async {
        final confirmed = await ConfirmationDialog.show(
          context,
          title: 'Delete "${scene.title}"?',
          message: 'This scene and its story text will be permanently removed.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        if (confirmed) await viewModel.deleteScene(scene.id);
      },
    );
  }
}

class _EmptyTimelineMessage extends StatelessWidget {
  const _EmptyTimelineMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No scenes yet. Tap "New Scene" to write the first chapter of your story.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NoResultsMessage extends StatelessWidget {
  const _NoResultsMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No scenes match your search or filters.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
