import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../animation/animation_overlay_factory.dart';
import '../../../creator/domain/entities/background_type.dart';
import '../../../creator/domain/entities/scene.dart';
import '../../../creator/domain/entities/scene_milestone_type.dart';
import '../../../creator/presentation/widgets/milestones/milestone_presentation.dart';
import '../../../player/presentation/widgets/media_video_player.dart';
import 'letter_view.dart';

/// Renders a single scene exactly as the Creator authored it: background
/// (gradient, solid color, photo, or video), date, and content — either
/// the rich [LetterView] reveal (when `Scene.letter` is set) or the
/// plain title/subtitle/story text (v1.1.0 behaviour, unchanged) — plus
/// its overlay animation slot and, if a [SceneMilestoneType] is set, a
/// themed cinematic treatment (v1.3.0) on top of everything else. This
/// is the only widget both Story Mode and Creator Mode's "Preview"
/// screen share — one source of visual truth.
class SceneView extends StatelessWidget {
  final Scene scene;

  const SceneView({super.key, required this.scene});

  Color _parseHexColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Resolves the "mood" gradient for this scene's milestone (v1.5.0
  /// Dynamic Background System) — falls back to the original
  /// [AppColors.romanticGradient] for `none` or any unmapped milestone,
  /// so a scene without a milestone renders exactly as it always has.
  /// Scene-to-scene transitions (already fading/sliding the whole
  /// [SceneView]) carry this change smoothly with no extra machinery.
  Gradient get _moodGradient {
    switch (scene.milestoneType) {
      case SceneMilestoneType.proposal:
        return AppColors.proposalMoodGradient;
      case SceneMilestoneType.wedding:
        return AppColors.weddingMoodGradient;
      case SceneMilestoneType.pregnancy:
        return AppColors.pregnancyMoodGradient;
      case SceneMilestoneType.babyBirth:
        return AppColors.babyBirthMoodGradient;
      case SceneMilestoneType.family:
        return AppColors.familyMoodGradient;
      case SceneMilestoneType.anniversary:
        return AppColors.anniversaryMoodGradient;
      case SceneMilestoneType.none:
        return AppColors.romanticGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProposal = scene.milestoneType == SceneMilestoneType.proposal;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Proposal scenes get a slow cinematic zoom + soft background
        // blur, per the v1.3.0 spec — every other milestone (and `none`)
        // renders the background exactly as before.
        isProposal
            ? _CameraZoomBackground(child: _buildBackground(blurred: true))
            : _buildBackground(blurred: false),
        Container(color: Colors.black.withValues(alpha: 0.35)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(DateFormatter.scene(scene.date), style: AppTextStyles.sceneDate, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: scene.letter != null
                      ? LetterView(
                          key: ValueKey('letter-${scene.id}'),
                          letter: scene.letter!,
                          fallbackTitle: scene.title,
                          fallbackSubtitle: scene.subtitle,
                        )
                      : _PlainSceneContent(scene: scene),
                ),
              ),
            ],
          ),
        ),
        AnimationOverlayFactory.resolve(scene.animationType),
        MilestonePresentation(scene: scene),
      ],
    );
  }

  Widget _buildBackground({required bool blurred}) {
    final background = switch (scene.backgroundType) {
      BackgroundType.solidColor => Container(
          color: scene.backgroundColorHex != null ? _parseHexColor(scene.backgroundColorHex!) : AppColors.midnightBlue,
        ),
      BackgroundType.photo => scene.photoPaths.isEmpty
          ? Container(decoration: BoxDecoration(gradient: _moodGradient))
          : (scene.milestoneType == SceneMilestoneType.wedding && scene.photoPaths.length > 1)
              ? _PhotoSlideshowBackground(photoPaths: scene.photoPaths, fallbackGradient: _moodGradient)
              : Image.file(
                  File(scene.photoPaths.first),
                  fit: BoxFit.cover,
                  // v1.4.0 perf pass: cap decode resolution — scene
                  // backgrounds render full-bleed but rarely need to
                  // decode at the source photo's full camera resolution.
                  cacheWidth: 1080,
                  errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(gradient: _moodGradient)),
                ),
      BackgroundType.video => scene.videoPaths.isEmpty
          ? Container(decoration: BoxDecoration(gradient: _moodGradient))
          : MediaVideoPlayer(videoPath: scene.videoPaths.first, autoPlay: true, loop: true),
      BackgroundType.romanticGradient => Container(decoration: BoxDecoration(gradient: _moodGradient)),
    };

    if (!blurred) return background;
    return ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: background);
  }
}

/// Slow, continuous "Ken Burns"-style zoom (1.0 → 1.08 and back) used
/// behind Proposal-milestone scenes for a cinematic camera-push feel.
class _CameraZoomBackground extends StatefulWidget {
  final Widget child;
  const _CameraZoomBackground({required this.child});

  @override
  State<_CameraZoomBackground> createState() => _CameraZoomBackgroundState();
}

class _CameraZoomBackgroundState extends State<_CameraZoomBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final scale = 1.0 + Curves.easeInOut.transform(_controller.value) * 0.08;
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

/// Auto-cycles through a scene's photos with a soft crossfade — the
/// Wedding milestone's "photo slideshow", used automatically whenever a
/// wedding-milestone scene has more than one photo attached.
class _PhotoSlideshowBackground extends StatefulWidget {
  final List<String> photoPaths;
  final Gradient fallbackGradient;
  const _PhotoSlideshowBackground({required this.photoPaths, required this.fallbackGradient});

  @override
  State<_PhotoSlideshowBackground> createState() => _PhotoSlideshowBackgroundState();
}

class _PhotoSlideshowBackgroundState extends State<_PhotoSlideshowBackground> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.photoPaths.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      child: Image.file(
        File(widget.photoPaths[_index]),
        key: ValueKey(widget.photoPaths[_index]),
        fit: BoxFit.cover,
        cacheWidth: 1080,
        errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(gradient: widget.fallbackGradient)),
      ),
    );
  }
}

/// The v1.0.0/v1.1.0 plain content layout — title, optional subtitle,
/// story text — used whenever a scene has no [Letter] attached.
class _PlainSceneContent extends StatelessWidget {
  final Scene scene;
  const _PlainSceneContent({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(scene.title, style: AppTextStyles.sceneTitle, textAlign: TextAlign.center),
        if (scene.subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            scene.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 22),
        Text(scene.storyText, style: AppTextStyles.storyBody, textAlign: TextAlign.center),
      ],
    );
  }
}
