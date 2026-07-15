import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../media/domain/entities/voice_note.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../../../media/presentation/widgets/waveform_widget.dart';
import 'audio_trim_editor.dart';

/// Record / stop / preview / delete a single voice-narration clip for a
/// scene, with a real waveform (captured live from microphone amplitude,
/// not synthesized) once a [VoiceNote] exists. Only one recording is
/// kept per scene; recording again replaces the previous clip.
///
/// [recordingPath]/[onChanged] are the plain v1.1.0 path-only contract,
/// kept fully working; [voiceNote]/[onVoiceNoteChanged] are the v1.2.0
/// additions carrying duration + waveform. Both are updated together on
/// every recording, so callers only using the legacy pair still work.
class VoiceRecorderWidget extends ConsumerStatefulWidget {
  final String? recordingPath;
  final ValueChanged<String?> onChanged;
  final VoiceNote? voiceNote;
  final ValueChanged<VoiceNote?>? onVoiceNoteChanged;

  const VoiceRecorderWidget({
    super.key,
    required this.recordingPath,
    required this.onChanged,
    this.voiceNote,
    this.onVoiceNoteChanged,
  });

  @override
  ConsumerState<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends ConsumerState<VoiceRecorderWidget> {
  bool _isRecording = false;
  String? _errorMessage;
  final List<double> _liveSamples = [];
  StreamSubscription<double>? _amplitudeSubscription;
  final Stopwatch _stopwatch = Stopwatch();

  final AudioPlayer _playbackPlayer = AudioPlayer();
  bool _isPlayingBack = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _playbackPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _playbackPosition = p);
      final trimEnd = widget.voiceNote?.trimEnd;
      if (_isPlayingBack && trimEnd != null && p >= trimEnd) {
        _playbackPlayer.pause();
        setState(() => _isPlayingBack = false);
      }
    });
    _playbackPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _playbackDuration = d);
    });
    _playbackPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingBack = false);
    });
  }

  Future<void> _startRecording() async {
    final recorder = ref.read(audioRecorderServiceProvider);
    try {
      await recorder.startRecording();
      _liveSamples.clear();
      _stopwatch
        ..reset()
        ..start();
      _amplitudeSubscription = recorder.amplitudeStream().listen((sample) {
        if (mounted) setState(() => _liveSamples.add(sample));
      });
      setState(() {
        _isRecording = true;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Microphone permission is required to record.');
    }
  }

  Future<void> _stopRecording() async {
    final recorder = ref.read(audioRecorderServiceProvider);
    await _amplitudeSubscription?.cancel();
    _stopwatch.stop();
    final path = await recorder.stopRecording();
    setState(() => _isRecording = false);

    if (path == null) return;

    widget.onChanged(path);
    widget.onVoiceNoteChanged?.call(VoiceNote(
      path: path,
      duration: _stopwatch.elapsed,
      waveform: List.of(_liveSamples),
      recordedAt: DateTime.now(),
    ));
  }

  Future<void> _togglePlayback(String path) async {
    if (_isPlayingBack) {
      await _playbackPlayer.pause();
      setState(() => _isPlayingBack = false);
    } else {
      final trimStart = widget.voiceNote?.trimStart ?? Duration.zero;
      await _playbackPlayer.play(DeviceFileSource(path), position: trimStart);
      setState(() => _isPlayingBack = true);
    }
  }

  /// Opens the shared [AudioTrimEditor] (v1.6.0) for the current
  /// recording — entirely non-destructive: only the trim range stored on
  /// [VoiceNote] changes, the recorded file on disk is untouched.
  Future<void> _trim(String path, VoiceNote? voiceNote) async {
    await _playbackPlayer.stop();
    setState(() => _isPlayingBack = false);
    if (!mounted) return;
    final result = await AudioTrimEditor.show(
      context,
      path: path,
      initialTrimStart: voiceNote?.trimStart ?? Duration.zero,
      initialTrimEnd: voiceNote?.trimEnd,
      waveform: voiceNote?.waveform ?? const [],
      title: 'Trim Voice Recording',
    );
    if (result == null || !mounted) return;
    final (start, end) = result;
    final base = voiceNote ?? VoiceNote(path: path, duration: _playbackDuration, recordedAt: DateTime.now());
    widget.onVoiceNoteChanged?.call(base.copyWith(trimStart: start, trimEnd: end, clearTrimEnd: end == null));
  }

  void _delete() {
    widget.onChanged(null);
    widget.onVoiceNoteChanged?.call(null);
    _playbackPlayer.stop();
    setState(() {
      _isPlayingBack = false;
      _playbackPosition = Duration.zero;
    });
  }

  Future<void> _rename(String path, VoiceNote? voiceNote) async {
    final controller = TextEditingController(text: voiceNote?.label ?? '');
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name this recording'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g. Dad's toast"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newLabel == null || !mounted) return;

    final updated = voiceNote?.copyWith(label: newLabel) ??
        VoiceNote(path: path, duration: Duration.zero, recordedAt: DateTime.now(), label: newLabel);
    widget.onVoiceNoteChanged?.call(updated);
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _playbackPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRecording = widget.recordingPath != null;
    final voiceNote = widget.voiceNote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voice Recording', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surfaceBlue, borderRadius: BorderRadius.circular(16)),
          child: _isRecording
              ? _buildRecordingRow()
              : hasRecording
                  ? _buildPlaybackRow(widget.recordingPath!, voiceNote)
                  : _buildIdleRow(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildIdleRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _startRecording,
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.rosePink,
            child: Icon(Icons.mic, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text('Tap to record a voice narration', style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildRecordingRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _stopRecording,
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.error,
            child: Icon(Icons.stop, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: WaveformWidget(
            samples: _liveSamples.length > 60 ? _liveSamples.sublist(_liveSamples.length - 60) : _liveSamples,
            progress: 1,
            height: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackRow(String path, VoiceNote? voiceNote) {
    final progress = _playbackDuration.inMilliseconds == 0
        ? 0.0
        : _playbackPosition.inMilliseconds / _playbackDuration.inMilliseconds;
    final label = voiceNote?.label.trim();
    final hasLabel = label != null && label.isNotEmpty;
    final isTrimmed = voiceNote?.isTrimmed ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontSize: 13)),
          ),
        if (isTrimmed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'ট্রিম করা: ${_format(voiceNote!.trimStart)} – ${_format(voiceNote.effectiveTrimEnd)}',
              style: const TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isPlayingBack ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: AppColors.gold,
                size: 30,
              ),
              onPressed: () => _togglePlayback(path),
            ),
            Expanded(
              child: voiceNote != null && voiceNote.waveform.isNotEmpty
                  ? WaveformWidget(samples: voiceNote.waveform, progress: progress.clamp(0.0, 1.0))
                  : Text(hasLabel ? '' : 'Voice narration', style: AppTextStyles.bodyMedium),
            ),
            IconButton(
              icon: const Icon(Icons.content_cut, color: AppColors.mutedWhite, size: 20),
              tooltip: 'Trim / Split',
              onPressed: () => _trim(path, voiceNote),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.mutedWhite, size: 20),
              tooltip: 'Rename',
              onPressed: () => _rename(path, voiceNote),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete,
            ),
          ],
        ),
      ],
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
