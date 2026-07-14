import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

/// Plays a local video file (a scene's `videoPaths` entry) with a
/// minimal, chrome-free control surface — tap to toggle play/pause.
/// Used by both the Scene Editor's media preview and Story Mode.
class MediaVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool loop;

  const MediaVideoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = false,
    this.loop = true,
  });

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller.initialize();
      await _controller.setLooping(widget.loop);
      if (widget.autoPlay) await _controller.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void didUpdateWidget(covariant MediaVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _controller.dispose();
      _initialized = false;
      _initialize();
    }
  }

  @override
  void dispose() {
    if (_initialized) _controller.dispose();
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

    return GestureDetector(
      onTap: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio == 0 ? 16 / 9 : _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
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
