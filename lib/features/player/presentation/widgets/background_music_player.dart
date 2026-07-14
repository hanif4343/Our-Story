import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Invisible controller that plays a scene's background music during
/// Story Mode autoplay, cross-fading between scenes' tracks and looping
/// each one for as long as its scene is on screen.
///
/// This is deliberately *not* built on [MediaAudioPlayer] (that widget
/// renders a visible scrub bar for Creator Mode's preview UI) — Story
/// Mode's music should never show playback controls, just play.
class BackgroundMusicController extends StatefulWidget {
  final String? musicPath;
  final bool enabled;
  final double volume;
  final Duration fadeDuration;

  const BackgroundMusicController({
    super.key,
    required this.musicPath,
    this.enabled = true,
    this.volume = 0.55,
    this.fadeDuration = const Duration(milliseconds: 700),
  });

  @override
  State<BackgroundMusicController> createState() => _BackgroundMusicControllerState();
}

class _BackgroundMusicControllerState extends State<BackgroundMusicController> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentPath;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _syncTrack(initial: true);
  }

  @override
  void didUpdateWidget(covariant BackgroundMusicController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.musicPath != widget.musicPath || oldWidget.enabled != widget.enabled) {
      _syncTrack();
    }
  }

  Future<void> _syncTrack({bool initial = false}) async {
    if (!widget.enabled || widget.musicPath == null) {
      if (!initial) await _fadeOutAndStop();
      _currentPath = null;
      return;
    }

    if (widget.musicPath == _currentPath) return;

    if (!initial && _currentPath != null) {
      await _fadeOutAndStop();
    }

    _currentPath = widget.musicPath;
    try {
      await _player.setVolume(0);
      await _player.play(DeviceFileSource(widget.musicPath!));
      await _fadeTo(widget.volume);
    } catch (_) {
      // A missing/corrupt music file should never crash Story Mode —
      // playback simply stays silent for that scene.
    }
  }

  Future<void> _fadeTo(double target) async {
    const steps = 12;
    final stepDuration = Duration(milliseconds: widget.fadeDuration.inMilliseconds ~/ steps);
    final current = await _player.getVolume() ?? 0.0;
    final delta = (target - current) / steps;
    for (var i = 0; i < steps; i++) {
      if (_isDisposed) return;
      await Future.delayed(stepDuration);
      await _player.setVolume((current + delta * (i + 1)).clamp(0.0, 1.0));
    }
  }

  Future<void> _fadeOutAndStop() async {
    await _fadeTo(0);
    if (!_isDisposed) await _player.stop();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
