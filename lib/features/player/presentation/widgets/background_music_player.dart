import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Invisible controller that plays a scene's background music during
/// Story Mode autoplay, cross-fading between scenes' tracks and looping
/// each one for as long as its scene is on screen.
///
/// [trimStart]/[trimEnd] (v1.6.0 Audio Trim Editor) let a scene's music
/// loop within just the Creator's chosen range instead of the whole
/// file — e.g. looping only the chorus. When both are left at their
/// defaults (zero / null) the track loops in full, exactly as before.
///
/// This is deliberately *not* built on [MediaAudioPlayer] (that widget
/// renders a visible scrub bar for Creator Mode's preview UI) — Story
/// Mode's music should never show playback controls, just play.
class BackgroundMusicController extends StatefulWidget {
  final String? musicPath;
  final bool enabled;
  final double volume;
  final Duration fadeDuration;
  final Duration trimStart;
  final Duration? trimEnd;

  const BackgroundMusicController({
    super.key,
    required this.musicPath,
    this.enabled = true,
    this.volume = 0.55,
    this.fadeDuration = const Duration(milliseconds: 700),
    this.trimStart = Duration.zero,
    this.trimEnd,
  });

  @override
  State<BackgroundMusicController> createState() => _BackgroundMusicControllerState();
}

class _BackgroundMusicControllerState extends State<BackgroundMusicController> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentPath;
  bool _isDisposed = false;
  // audioplayers' AudioPlayer has no getter for the current volume — only
  // setVolume(). We track the last value we set locally so _fadeTo can
  // compute a smooth ramp from wherever the volume currently sits.
  double _currentVolume = 0.0;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    // Untrimmed tracks (the common case) keep using audioplayers' native
    // loop mode; a trimmed track needs a manual loop (see
    // _watchForLoopPoint) so it can jump back to trimStart instead of 0.
    _player.setReleaseMode(widget.trimEnd == null ? ReleaseMode.loop : ReleaseMode.stop);
    _watchForLoopPoint();
    _syncTrack(initial: true);
  }

  @override
  void didUpdateWidget(covariant BackgroundMusicController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trimEnd != widget.trimEnd) {
      _player.setReleaseMode(widget.trimEnd == null ? ReleaseMode.loop : ReleaseMode.stop);
    }
    if (oldWidget.musicPath != widget.musicPath || oldWidget.enabled != widget.enabled) {
      _syncTrack();
    }
  }

  /// For a trimmed track, [ReleaseMode.stop] means playback simply stops
  /// once it reaches [Duration]'s natural end or our own seek target —
  /// so we watch the position stream and seek back to [trimStart]
  /// whenever it reaches [trimEnd], giving a manual loop bounded to the
  /// trimmed range.
  void _watchForLoopPoint() {
    _positionSubscription = _player.onPositionChanged.listen((position) {
      final trimEnd = widget.trimEnd;
      if (trimEnd == null) return;
      if (position >= trimEnd) {
        _player.seek(widget.trimStart);
      }
    });
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
      _currentVolume = 0.0;
      await _player.play(DeviceFileSource(widget.musicPath!), position: widget.trimStart);
      await _fadeTo(widget.volume);
    } catch (_) {
      // A missing/corrupt music file should never crash Story Mode —
      // playback simply stays silent for that scene.
    }
  }

  Future<void> _fadeTo(double target) async {
    const steps = 12;
    final stepDuration = Duration(milliseconds: widget.fadeDuration.inMilliseconds ~/ steps);
    final current = _currentVolume;
    final delta = (target - current) / steps;
    for (var i = 0; i < steps; i++) {
      if (_isDisposed) return;
      await Future.delayed(stepDuration);
      _currentVolume = (current + delta * (i + 1)).clamp(0.0, 1.0);
      await _player.setVolume(_currentVolume);
    }
  }

  Future<void> _fadeOutAndStop() async {
    await _fadeTo(0);
    if (!_isDisposed) await _player.stop();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
