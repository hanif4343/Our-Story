import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../viewmodels/creator_viewmodel.dart';

/// Creator Mode's landing screen after unlocking — a warm overview of
/// the story so far (scene count, years spanned, chapters, favorites)
/// plus quick entry points into the Scene List, a new scene, Story
/// Mode preview, and Settings.
class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creatorViewModelProvider);
    final scenes = state.scenes;

    final totalScenes = scenes.length;
    final totalYears = scenes.map((s) => s.year).toSet().length;
    final totalChapters = scenes.map((s) => s.chapter).where((c) => c.trim().isNotEmpty).toSet().length;
    final totalFavorites = scenes.where((s) => s.isFavorite).length;
    final totalPhotos = scenes.fold<int>(0, (sum, s) => sum + s.photoPaths.length);
    final totalVideos = scenes.fold<int>(0, (sum, s) => sum + s.videoPaths.length);
    final totalVoiceRecordings = scenes.where((s) => s.voiceRecordingPath != null).length;

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async => ref.read(creatorViewModelProvider.notifier).loadScenes(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.romanticGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_stories_outlined, color: AppColors.gold, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    totalScenes == 0
                        ? 'Your story is waiting to be written.'
                        : 'Your story has $totalScenes ${totalScenes == 1 ? 'scene' : 'scenes'} so far.',
                    style: AppTextStyles.sceneTitle.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(icon: Icons.movie_creation_outlined, label: 'Scenes', value: '$totalScenes'),
                _StatCard(icon: Icons.calendar_today_outlined, label: 'Years', value: '$totalYears'),
                _StatCard(icon: Icons.menu_book_outlined, label: 'Chapters', value: '$totalChapters'),
                _StatCard(icon: Icons.favorite, label: 'Favorites', value: '$totalFavorites'),
                _StatCard(icon: Icons.photo_library_outlined, label: 'Photos', value: '$totalPhotos'),
                _StatCard(icon: Icons.videocam_outlined, label: 'Videos', value: '$totalVideos'),
                _StatCard(icon: Icons.mic_outlined, label: 'Voice Notes', value: '$totalVoiceRecordings'),
              ],
            ),
            const SizedBox(height: 28),
            Text('Quick Actions', style: AppTextStyles.label),
            const SizedBox(height: 12),
            AppButton(
              label: 'View Scene List',
              icon: Icons.list_alt_outlined,
              expand: true,
              onPressed: () => context.push(AppRoutes.creatorHome),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Manage Chapters',
              icon: Icons.menu_book_outlined,
              variant: AppButtonVariant.outline,
              expand: true,
              onPressed: () => context.push(AppRoutes.chapterList),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Write New Scene',
              icon: Icons.add_circle_outline,
              variant: AppButtonVariant.outline,
              expand: true,
              onPressed: () => context.push(AppRoutes.sceneCreate),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Preview as Story',
              icon: Icons.play_circle_outline,
              variant: AppButtonVariant.outline,
              expand: true,
              onPressed: totalScenes == 0 ? null : () => context.push(AppRoutes.storyIntro),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Cinematic Timeline',
              icon: Icons.timeline_outlined,
              variant: AppButtonVariant.outline,
              expand: true,
              onPressed: totalScenes == 0 ? null : () => context.push(AppRoutes.cinematicTimeline),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.sceneTitle.copyWith(fontSize: 22)),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
