import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Photo attachment UI for the Scene Editor: unlimited photos, each
/// rendered as a real thumbnail (not a placeholder icon), tappable for a
/// full-screen preview with Replace/Delete actions, and — when
/// [onReorder] is provided (v1.4.0) — drag-to-reorder.
class MediaPickerSection extends StatelessWidget {
  final List<String> photoPaths;
  final VoidCallback onAddPhoto;
  final ValueChanged<String> onRemovePhoto;

  /// Optional: when provided, the full-screen preview offers a "Replace"
  /// action for the tapped photo (receives the path being replaced).
  final ValueChanged<String>? onReplacePhoto;

  /// Optional (v1.4.0): when provided, photos become drag-to-reorder.
  /// Indices refer to positions within [photoPaths].
  final void Function(int oldIndex, int newIndex)? onReorder;

  const MediaPickerSection({
    super.key,
    required this.photoPaths,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    this.onReplacePhoto,
    this.onReorder,
  });

  void _openPreview(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.file(
                File(path),
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onReplacePhoto != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReplacePhoto!(path);
                      },
                      icon: const Icon(Icons.swap_horiz, color: AppColors.gold, size: 18),
                      label: const Text('Replace', style: TextStyle(color: AppColors.gold)),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRemovePhoto(path);
                    },
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String path) {
    return Padding(
      key: ValueKey(path),
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _openPreview(context, path),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 90,
                height: 90,
                color: AppColors.surfaceBlue,
                child: Image.file(
                  File(path),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  // Decoding at the display resolution (rather than full
                  // camera resolution) keeps scrolling this row smooth
                  // even with many photos attached (v1.4.0 perf pass).
                  cacheWidth: 180,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.mutedWhite),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => onRemovePhoto(path),
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Photos', style: AppTextStyles.label),
            Text('${photoPaths.length} added', style: AppTextStyles.label.copyWith(color: AppColors.mutedWhite)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: onReorder != null && photoPaths.isNotEmpty
              ? ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  onReorder: onReorder!,
                  footer: GestureDetector(
                    key: const ValueKey('add-photo-button'),
                    onTap: onAddPhoto,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.mutedWhite.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold),
                    ),
                  ),
                  children: [for (final path in photoPaths) _buildThumbnail(context, path)],
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...photoPaths.map((path) => _buildThumbnail(context, path)),
                    GestureDetector(
                      onTap: onAddPhoto,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mutedWhite.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
