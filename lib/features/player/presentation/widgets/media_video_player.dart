import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

/// Plays a local video file (a scene's `videoPaths` entry) full-bleed,
/// covering its bounds exactly like a photo background would (no
/// letterboxing), with a minimal, chrome-free control surface — tap to
/// toggle play/pause. Used by both the Scene Editor's media preview and
/// Story Mode.
///
/// When [onEnded] is provided, [loop] is ignored: the video plays once,
/// start to finish, and [onEnded] fires exactly once when it completes —
/// this is how Story Mode lets a video scene run for its own full
/// length instead of a fixed timer.
class MediaVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool loop;
  final VoidCallback? onEnded;

  /// When non-null, playback is driven externally instead of this
  /// widget's own built-in tap-to-toggle gesture — set it to
  /// `true`/`false` to pause/resume the video in lockstep with that
  /// external state. Story Mode uses this so tapping anywhere on
  /// screen to pause the story also actually pauses the video playing
  /// underneath it, instead of leaving it silently running. Leave
  /// `null` (the default) to keep the original self-contained
  /// behaviour, where tapping the video itself toggles play/pause.
  final bool? isPaused;

  const MediaVideoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = false,
    this.loop = true,
    this.onEnded,
    this.isPaused,
  });

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _endedFired = false;

  bool get _playsOnce => widget.onEnded != null;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = VideoPlayerController.file(File(widget.videoPath));
      await controller.initialize();
      await controller.setLooping(_playsOnce ? false : widget.loop);
      controller.addListener(_handleControllerUpdate);
      _controller = controller;
      if (widget.autoPlay && widget.isPaused != true) await _controller.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _handleControllerUpdate() {
    if (!mounted) return;
    final value = _controller.value;

    if (value.isPlaying != _isPlaying) {
      setState(() => _isPlaying = value.isPlaying);
    }

    // Fire the completion callback once, right as a non-looping video
    // finishes its one and only playthrough.
    if (widget.onEnded != null &&
        !_endedFired &&
        value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      _endedFired = true;
      widget.onEnded!();
    }
  }

  @override
  void didUpdateWidget(covariant MediaVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _controller.removeListener(_handleControllerUpdate);
      _controller.dispose();
      _initialized = false;
      _endedFired = false;
      _initialize();
      return;
    }

    // Keep the video in lockstep with an externally driven pause state
    // (e.g. Story Mode's screen-level tap-to-pause) — so pausing the
    // story also actually pauses the video playing underneath it.
    if (_initialized && widget.isPaused != null && widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused == true) {
        _controller.pause();
      } else if (!_playsOnce || !_endedFired) {
        _controller.play();
      }
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.removeListener(_handleControllerUpdate);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppColors.surfaceBlue,
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline, color: AppColors.mutedWhite, size: 32),
      );
    }

    if (!_initialized) {
      return Container(
        color: AppColors.surfaceBlue,
        alignment: Alignment.center,
        child: const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
        ),
      );
    }

    final size = _controller.value.size;
    final videoWidth = size.width == 0 ? 16.0 : size.width;
    final videoHeight = size.height == 0 ? 9.0 : size.height;

    return GestureDetector(
      // When playback is externally driven (Story Mode), the
      // screen-level tap-to-pause already owns the tap gesture and
      // this widget just follows `isPaused` — so it steps aside here
      // instead of also toggling on its own and fighting that state.
      onTap: widget.isPaused != null
          ? null
          : () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          // Cover-fill, matching how a photo background renders — the
          // video always fills the frame with no black letterbox bars,
          // cropping evenly instead of shrinking to fit.
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoWidth,
                height: videoHeight,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          if (!_isPlaying)
            Container(
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
        ],
      ),
    );
  }
}
