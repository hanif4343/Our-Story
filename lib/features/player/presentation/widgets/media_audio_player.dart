import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Plays a local audio file (background music or a voice recording) with
/// a compact play/pause + scrub UI. Used by the Scene Editor's music &
/// voice-note preview, and by Story Mode for background-music playback.
class MediaAudioPlayer extends StatefulWidget {
  final String? audioPath;
  final bool compact;

  const MediaAudioPlayer({super.key, this.audioPath, this.compact = true});

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
      if (mounted) setState(() => _position = p);
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
      await _player.play(DeviceFileSource(path));
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
              value: _duration.inMilliseconds == 0
                  ? 0
                  : _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
              max: _duration.inMilliseconds == 0 ? 1 : _duration.inMilliseconds.toDouble(),
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
