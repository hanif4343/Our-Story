import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../media/presentation/providers/media_providers.dart';

/// Attach/preview/remove an unlimited number of video clips for a scene.
/// Mirrors [MediaPickerSection]'s layout language but renders a
/// generated thumbnail (via [ThumbnailService]) instead of a static icon
/// wherever possible, falling back gracefully while it loads. Supports
/// drag-to-reorder (v1.4.0) when [onReorder] is provided.
class VideoPickerSection extends ConsumerWidget {
  final List<String> videoPaths;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final void Function(int oldIndex, int newIndex)? onReorder;

  const VideoPickerSection({
    super.key,
    required this.videoPaths,
    required this.onAdd,
    required this.onRemove,
    this.onReorder,
  });

  Future<void> _pickVideo(BuildContext context, WidgetRef ref) async {
    try {
      final path = await ref.read(videoPickerServiceProvider).pickVideo();
      if (path != null) onAdd(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add video: $e')));
      }
    }
  }

  Widget _buildThumbnail(String path) {
    return Padding(
      key: ValueKey(path),
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          _VideoThumbnail(path: path),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => onRemove(path),
              child: const CircleAvatar(
                radius: 11,
                backgroundColor: AppColors.error,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          if (onReorder != null)
            const Positioned(
              bottom: 2,
              left: 2,
              child: Icon(Icons.drag_indicator, size: 14, color: Colors.white70),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Videos', style: AppTextStyles.label),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: onReorder != null && videoPaths.isNotEmpty
              ? ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  onReorderItem: (oldIndex, newIndex) {
                    // onReorderItem already adjusts newIndex for the
                    // removed item at oldIndex; translate back to the
                    // classic (oldIndex, newIndex) shape so the existing
                    // "if (newIndex > oldIndex) newIndex -= 1" logic in
                    // the view model keeps working unchanged.
                    final legacyNewIndex = newIndex >= oldIndex ? newIndex + 1 : newIndex;
                    onReorder!(oldIndex, legacyNewIndex);
                  },
                  footer: GestureDetector(
                    key: const ValueKey('add-video-button'),
                    onTap: () => _pickVideo(context, ref),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.mutedWhite.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.video_call_outlined, color: AppColors.gold),
                    ),
                  ),
                  children: [for (final path in videoPaths) _buildThumbnail(path)],
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...videoPaths.map(_buildThumbnail),
                    GestureDetector(
                      onTap: () => _pickVideo(context, ref),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mutedWhite.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.video_call_outlined, color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _VideoThumbnail extends ConsumerStatefulWidget {
  final String path;
  const _VideoThumbnail({required this.path});

  @override
  ConsumerState<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends ConsumerState<_VideoThumbnail> {
  String? _thumbnailPath;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final path = await ref.read(thumbnailServiceProvider).generateForVideo(widget.path);
      if (mounted) setState(() => _thumbnailPath = path);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 90,
        height: 90,
        color: AppColors.surfaceBlue,
        alignment: Alignment.center,
        child: _thumbnailPath != null
            ? Image.file(
                File(_thumbnailPath!),
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                // v1.4.0 perf pass: decode at display resolution.
                cacheWidth: 180,
                errorBuilder: (_, __, ___) => const Icon(Icons.movie_outlined, color: AppColors.mutedWhite),
              )
            : Icon(
                _failed ? Icons.movie_outlined : Icons.hourglass_bottom,
                color: AppColors.mutedWhite,
              ),
      ),
    );
  }
}
