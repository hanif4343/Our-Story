import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player/presentation/widgets/media_audio_player.dart';
import '../../../story/presentation/widgets/scene_view.dart';
import '../../domain/entities/scene.dart';

/// Lets the Creator see exactly how a single scene will look in Story
/// Mode — without leaving Creator Mode or auto-advancing through the
/// rest of the timeline. Reuses [SceneView], the same renderer Story
/// Mode itself uses, so there is exactly one source of visual truth.
class ScenePreviewScreen extends StatelessWidget {
  final Scene scene;
  const ScenePreviewScreen({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      body: Stack(
        children: [
          Positioned.fill(child: SceneView(scene: scene)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () {
                      context.pop();
                      context.push(AppRoutes.sceneEdit, extra: scene);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (scene.musicPath != null || scene.voiceRecordingPath != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: MediaAudioPlayer(
                    audioPath: scene.musicPath ?? scene.voiceRecordingPath,
                    trimStart: scene.musicPath != null ? scene.musicTrimStart : (scene.voiceNote?.trimStart ?? Duration.zero),
                    trimEnd: scene.musicPath != null ? scene.musicTrimEnd : scene.voiceNote?.trimEnd,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
