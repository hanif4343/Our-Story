import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../media/presentation/widgets/waveform_widget.dart';

/// A shared trim/split editor for any local audio file — used for both
/// voice recordings and background music (v1.6.0 Audio Trim Editor).
///
/// Entirely non-destructive: the source file on disk is never touched.
/// The Creator drags the two range handles to choose how many seconds
/// to keep, or plays the clip and taps "Set start here" / "Set end
/// here" to snap a handle to the exact playhead position (a precise,
/// tap-driven way to "split" the clip into a kept and a discarded part).
/// Every change is pushed onto an undo stack, so "Undo" always steps
/// back one change at a time.
///
/// Returns the chosen `(start, end)` range via [show] — `end` is `null`
/// when the Creator kept the clip's natural end (no end trim).
class AudioTrimEditor extends StatefulWidget {
  final String path;
  final Duration initialTrimStart;
  final Duration? initialTrimEnd;
  final List<double> waveform;
  final String title;

  const AudioTrimEditor({
    super.key,
    required this.path,
    this.initialTrimStart = Duration.zero,
    this.initialTrimEnd,
    this.waveform = const [],
    this.title = 'Trim Audio',
  });

  /// Convenience launcher: shows this editor in a scroll-controlled
  /// modal bottom sheet and returns the chosen range, or `null` if the
  /// Creator dismissed without applying.
  static Future<(Duration, Duration?)?> show(
    BuildContext context, {
    required String path,
    Duration initialTrimStart = Duration.zero,
    Duration? initialTrimEnd,
    List<double> waveform = const [],
    String title = 'Trim Audio',
  }) {
    return showModalBottomSheet<(Duration, Duration?)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.deepBlue,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AudioTrimEditor(
        path: path,
        initialTrimStart: initialTrimStart,
        initialTrimEnd: initialTrimEnd,
        waveform: waveform,
        title: title,
      ),
    );
  }

  @override
  State<AudioTrimEditor> createState() => _AudioTrimEditorState();
}

class _AudioTrimEditorState extends State<AudioTrimEditor> {
  final AudioPlayer _player = AudioPlayer();

  bool _loading = true;
  String? _error;
  Duration _total = Duration.zero;
  Duration _start = Duration.zero;
  Duration _end = Duration.zero;
  Duration _playhead = Duration.zero;
  bool _isPlaying = false;

  /// Undo history: every committed change to (start, end) is pushed here
  /// before it's applied, so "Undo" always restores the previous range.
  final List<(Duration, Duration)> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _playhead = p);
      if (_isPlaying && p >= _end) {
        _player.pause();
        setState(() => _isPlaying = false);
      }
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _load() async {
    try {
      await _player.setSource(DeviceFileSource(widget.path));
      final duration = await _player.getDuration() ?? Duration.zero;
      if (!mounted) return;
      setState(() {
        _total = duration;
        _start = widget.initialTrimStart;
        _end = widget.initialTrimEnd ?? duration;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not read this audio file.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _pushHistory() => _history.add((_start, _end));

  void _undo() {
    if (_history.isEmpty) return;
    final (previousStart, previousEnd) = _history.removeLast();
    setState(() {
      _start = previousStart;
      _end = previousEnd;
    });
  }

  void _reset() {
    if (_start == Duration.zero && _end == _total) return;
    _pushHistory();
    setState(() {
      _start = Duration.zero;
      _end = _total;
    });
  }

  Future<void> _togglePreview() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(widget.path), position: _start);
      setState(() => _isPlaying = true);
    }
  }

  /// Snaps the start handle to the current playhead — the tap-driven
  /// way to "split" off and discard everything before this point.
  void _setStartAtPlayhead() {
    final candidate = _playhead < _end - const Duration(milliseconds: 300) ? _playhead : _end - const Duration(milliseconds: 300);
    if (candidate == _start || candidate < Duration.zero) return;
    _pushHistory();
    setState(() => _start = candidate);
  }

  /// Snaps the end handle to the current playhead — the tap-driven way
  /// to "split" off and discard everything after this point.
  void _setEndAtPlayhead() {
    final candidate = _playhead > _start + const Duration(milliseconds: 300) ? _playhead : _start + const Duration(milliseconds: 300);
    if (candidate == _end || candidate > _total) return;
    _pushHistory();
    final clamped = candidate < Duration.zero
        ? Duration.zero
        : (candidate > _total ? _total : candidate);
    setState(() => _end = clamped);
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: _loading
              ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
              : _error != null
                  ? SizedBox(height: 120, child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.error))))
                  : SingleChildScrollView(child: _buildEditor(context)),
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final totalMs = _total.inMilliseconds.clamp(1, 1 << 30).toDouble();
    final keptDuration = _end - _start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(icon: const Icon(Icons.close, color: AppColors.mutedWhite), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        Text(
          'কতটুকু রাখবেন সেটা ঠিক করতে হ্যান্ডেল দুটো সামনে-পিছনে টানুন, অথবা প্লে করে ঠিক জায়গায় "Start"/"End" বসিয়ে দিন।',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedWhite, fontSize: 12),
        ),
        const SizedBox(height: 16),
        WaveformWidget(
          samples: widget.waveform,
          progress: _total.inMilliseconds == 0 ? 0 : (_playhead.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0),
          height: 56,
        ),
        RangeSlider(
          values: RangeValues(
            _start.inMilliseconds.toDouble().clamp(0, totalMs),
            _end.inMilliseconds.toDouble().clamp(0, totalMs),
          ),
          min: 0,
          max: totalMs,
          activeColor: AppColors.gold,
          inactiveColor: AppColors.surfaceBlue,
          labels: RangeLabels(_format(_start), _format(_end)),
          onChanged: (values) {
            setState(() {
              _start = Duration(milliseconds: values.start.round());
              _end = Duration(milliseconds: values.end.round());
            });
          },
          onChangeStart: (_) => _pushHistory(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('শুরু ${_format(_start)}', style: const TextStyle(color: AppColors.mutedWhite, fontSize: 12)),
            Text('মোট রাখা হচ্ছে: ${_format(keptDuration)}', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('শেষ ${_format(_end)}', style: const TextStyle(color: AppColors.mutedWhite, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.surfaceBlue, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.gold, size: 32),
                onPressed: _togglePreview,
              ),
              Expanded(
                child: Text('প্লেহেড: ${_format(_playhead)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              TextButton(onPressed: _setStartAtPlayhead, child: const Text('Start এখানে')),
              TextButton(onPressed: _setEndAtPlayhead, child: const Text('End এখানে')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            TextButton.icon(
              onPressed: _history.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Undo (ব্যাক)'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('পুরোটা রাখো'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.deepBlue),
                onPressed: keptDuration.inMilliseconds <= 0
                    ? null
                    : () => Navigator.of(context).pop((_start, _end >= _total ? null : _end)),
                child: const Text('এই অংশটুকু রাখো'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
