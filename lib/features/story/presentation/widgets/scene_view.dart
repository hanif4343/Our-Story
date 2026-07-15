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

  /// Called once when this scene's background video finishes playing a
  /// single full playthrough. Only relevant when the scene actually has
  /// a video background — ignored otherwise. Story Mode uses this to
  /// advance to the next scene once the video's own length is done,
  /// instead of a fixed timer (see [StoryViewModel.onVideoFinished]).
  /// Leave null (e.g. the Creator's static Preview screen) to have the
  /// video loop continuously instead.
  final VoidCallback? onVideoEnded;

  const SceneView({super.key, required this.scene, this.onVideoEnded});

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
    // A scene's attached photo(s)/video always take priority over the
    // manually chosen background type below — that setting only matters
    // as a fallback for scenes with no media attached at all. This way
    // adding a photo or video to a scene is enough for it to actually
    // play; there's no separate switch to remember to flip.
    final Widget background;
    if (scene.videoPaths.isNotEmpty) {
      background = MediaVideoPlayer(
        videoPath: scene.videoPaths.first,
        autoPlay: true,
        loop: onVideoEnded == null,
        onEnded: onVideoEnded,
      );
    } else if (scene.photoPaths.isNotEmpty) {
      background = (scene.milestoneType == SceneMilestoneType.wedding && scene.photoPaths.length > 1)
          ? _PhotoSlideshowBackground(photoPaths: scene.photoPaths, fallbackGradient: _moodGradient)
          : _CoverPhoto(path: scene.photoPaths.first, fallbackGradient: _moodGradient);
    } else {
      background = switch (scene.backgroundType) {
        BackgroundType.solidColor => Container(
            color: scene.backgroundColorHex != null ? _parseHexColor(scene.backgroundColorHex!) : AppColors.midnightBlue,
          ),
        BackgroundType.photo || BackgroundType.video || BackgroundType.romanticGradient =>
          Container(decoration: BoxDecoration(gradient: _moodGradient)),
      };
    }

    if (!blurred) return background;
    return ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: background);
  }
}

/// Renders a scene photo so the whole image always stays visible,
/// regardless of its aspect ratio relative to the screen. A landscape
/// photo on a tall phone screen used to be forced to fill the frame
/// with a hard `BoxFit.cover`, which zoomed in and cropped away most of
/// the image. Instead this shows the full photo (`BoxFit.contain`) over
/// a softly blurred, zoomed-in copy of the same photo as a backdrop —
/// so there's never an empty bar and the subject is never cropped off.
class _CoverPhoto extends StatelessWidget {
  final String path;
  final Gradient fallbackGradient;
  const _CoverPhoto({super.key, required this.path, required this.fallbackGradient});

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            // Small decode target — this copy is just a blurred
            // backdrop, it never needs to be sharp.
            cacheWidth: 400,
            errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(gradient: fallbackGradient)),
          ),
        ),
        Image.file(
          file,
          fit: BoxFit.contain,
          // v1.4.0 perf pass: cap decode resolution — scene
          // backgrounds render full-bleed but rarely need to decode at
          // the source photo's full camera resolution.
          cacheWidth: 1080,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ],
    );
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
      child: _CoverPhoto(
        key: ValueKey(widget.photoPaths[_index]),
        path: widget.photoPaths[_index],
        fallbackGradient: widget.fallbackGradient,
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
