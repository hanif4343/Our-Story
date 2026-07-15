import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../player/presentation/widgets/media_audio_player.dart';
import 'audio_trim_editor.dart';

/// Pick, preview, and clear the scene's background-music track. Actual
/// file selection is wired by the caller (via [onPick], invoking
/// `MusicPickerService`) — this widget stays focused purely on display.
///
/// [trimStart]/[trimEnd]/[onTrimChanged] are the v1.6.0 Audio Trim
/// Editor hooks — optional so any older caller not yet passing them
/// still compiles and behaves exactly as before (full track, no trim).
class MusicSelector extends StatelessWidget {
  final String? selectedPath;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final Duration trimStart;
  final Duration? trimEnd;
  final void Function(Duration start, Duration? end)? onTrimChanged;

  const MusicSelector({
    super.key,
    this.selectedPath,
    required this.onPick,
    required this.onClear,
    this.trimStart = Duration.zero,
    this.trimEnd,
    this.onTrimChanged,
  });

  String _fileName(String path) => path.split('/').last;

  Future<void> _trim(BuildContext context) async {
    final path = selectedPath;
    if (path == null) return;
    final result = await AudioTrimEditor.show(
      context,
      path: path,
      initialTrimStart: trimStart,
      initialTrimEnd: trimEnd,
      title: 'Trim Background Music',
    );
    if (result == null) return;
    final (start, end) = result;
    onTrimChanged?.call(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final isTrimmed = trimStart > Duration.zero || trimEnd != null;

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
                  if (selectedPath != null && onTrimChanged != null)
                    IconButton(
                      icon: const Icon(Icons.content_cut, size: 18, color: AppColors.mutedWhite),
                      tooltip: 'Trim / Split',
                      onPressed: () => _trim(context),
                    ),
                  if (selectedPath != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.mutedWhite),
                      onPressed: onClear,
                    ),
                  TextButton(onPressed: onPick, child: const Text('Choose')),
                ],
              ),
              if (selectedPath != null && isTrimmed) ...[
                const SizedBox(height: 4),
                Text(
                  'ট্রিম করা: ${_format(trimStart)} – ${trimEnd != null ? _format(trimEnd!) : 'শেষ পর্যন্ত'}',
                  style: const TextStyle(color: AppColors.gold, fontSize: 11),
                ),
              ],
              if (selectedPath != null) ...[
                const SizedBox(height: 4),
                MediaAudioPlayer(audioPath: selectedPath, trimStart: trimStart, trimEnd: trimEnd),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
