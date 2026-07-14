import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../player/presentation/widgets/media_audio_player.dart';

/// Pick, preview, and clear the scene's background-music track. Actual
/// file selection is wired by the caller (via [onPick], invoking
/// `MusicPickerService`) — this widget stays focused purely on display.
class MusicSelector extends StatelessWidget {
  final String? selectedPath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const MusicSelector({super.key, this.selectedPath, required this.onPick, required this.onClear});

  String _fileName(String path) => path.split('/').last;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Music', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.music_note_outlined, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedPath != null ? _fileName(selectedPath!) : 'No track selected',
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedPath != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.mutedWhite),
                      onPressed: onClear,
                    ),
                  TextButton(onPressed: onPick, child: const Text('Choose')),
                ],
              ),
              if (selectedPath != null) ...[
                const SizedBox(height: 4),
                MediaAudioPlayer(audioPath: selectedPath),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
