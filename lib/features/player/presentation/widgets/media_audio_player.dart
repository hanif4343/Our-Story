import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Plays a local audio file (background music or a voice recording) with
/// a compact play/pause + scrub UI. Used by the Scene Editor's music &
/// voice-note preview, and by Story Mode for background-music playback.
///
/// [trimStart]/[trimEnd] (v1.6.0 Audio Trim Editor) are optional — when
/// provided, playback and the scrub bar are both clamped to that range
/// instead of the file's full length, so the preview always matches
/// what the Creator actually trimmed. Omitting them plays the whole
/// file exactly as before.
class MediaAudioPlayer extends StatefulWidget {
  final String? audioPath;
  final bool compact;
  final Duration trimStart;
  final Duration? trimEnd;

  const MediaAudioPlayer({super.key, this.audioPath, this.compact = true, this.trimStart = Duration.zero, this.trimEnd});

  @override
  State<MediaAudioPlayer> createState() => _MediaAudioPlayerState();
}

class _MediaAudioPlayerState extends State<MediaAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
      final trimEnd = widget.trimEnd;
      if (_isPlaying && trimEnd != null && p >= trimEnd) {
        _player.pause();
        setState(() => _isPlaying = false);
      }
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void didUpdateWidget(covariant MediaAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath) {
      _player.stop();
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    }
  }

  Future<void> _toggle() async {
    final path = widget.audioPath;
    if (path == null) return;
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      // Resume from wherever the scrub bar is, unless that position now
      // falls outside the trimmed range — then snap back to trimStart.
      final resumeAt =
          _position < widget.trimStart || (widget.trimEnd != null && _position >= widget.trimEnd!) ? widget.trimStart : _position;
      await _player.play(DeviceFileSource(path), position: resumeAt);
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioPath == null) return const SizedBox.shrink();

    final rangeStart = widget.trimStart.inMilliseconds.toDouble();
    final rangeEnd = widget.trimEnd != null
        ? widget.trimEnd!.inMilliseconds.toDouble()
        : (_duration.inMilliseconds == 0 ? rangeStart + 1 : _duration.inMilliseconds.toDouble());
    final sliderMax = rangeEnd > rangeStart ? rangeEnd : rangeStart + 1;
    final sliderValue = _position.inMilliseconds.toDouble().clamp(rangeStart, sliderMax);

    return Row(
      children: [
        IconButton(
          onPressed: _toggle,
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: AppColors.gold,
            size: 34,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: sliderValue,
              min: rangeStart,
              max: sliderMax,
              activeColor: AppColors.rosePink,
              inactiveColor: AppColors.surfaceBlue,
              onChanged: (value) => _player.seek(Duration(milliseconds: value.round())),
            ),
          ),
        ),
        Text(_format(_position), style: const TextStyle(color: AppColors.mutedWhite, fontSize: 11)),
        const SizedBox(width: 8),
      ],
    );
  }
}
