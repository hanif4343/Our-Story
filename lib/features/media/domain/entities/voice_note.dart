import 'package:equatable/equatable.dart';

/// A recorded voice narration attached to a scene, including a
/// lightweight waveform (amplitude samples captured live during
/// recording) so playback UI can render a real waveform instead of a
/// generic audio icon.
///
/// This is the richer, persisted successor to the plain
/// `Scene.voiceRecordingPath` string introduced in v1.1.0 — that field
/// is kept fully intact for backward compatibility; `VoiceNote` is
/// additive and, when present, is what the v1.2.0 waveform player uses.
class VoiceNote extends Equatable {
  final String path;
  final Duration duration;

  /// Normalized amplitude samples (0.0–1.0) captured during recording,
  /// used to render a waveform without re-decoding the audio file.
  final List<double> waveform;

  final DateTime recordedAt;

  /// Creator-given name for this recording (v1.4.0), e.g. "Dad's toast".
  /// Empty means unnamed — playback UI falls back to a generic label.
  final String label;

  /// Non-destructive trim range (v1.6.0 Audio Trim Editor). The original
  /// recording on disk is never modified — only playback is clipped to
  /// `[trimStart, trimEnd]`. [trimStart] defaults to the very start;
  /// [trimEnd] of `null` means "play through to the natural end", so an
  /// untrimmed recording behaves exactly as it always has.
  final Duration trimStart;
  final Duration? trimEnd;

  const VoiceNote({
    required this.path,
    required this.duration,
    this.waveform = const [],
    required this.recordedAt,
    this.label = '',
    this.trimStart = Duration.zero,
    this.trimEnd,
  });

  /// The effective end of playback: the explicit trim point if set,
  /// otherwise the recording's full duration.
  Duration get effectiveTrimEnd => trimEnd ?? duration;

  /// Whether this recording has been trimmed to something shorter than
  /// its full original length.
  bool get isTrimmed => trimStart > Duration.zero || (trimEnd != null && trimEnd! < duration);

  VoiceNote copyWith({
    String? path,
    Duration? duration,
    List<double>? waveform,
    DateTime? recordedAt,
    String? label,
    Duration? trimStart,
    Duration? trimEnd,
    bool clearTrimEnd = false,
  }) {
    return VoiceNote(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      waveform: waveform ?? this.waveform,
      recordedAt: recordedAt ?? this.recordedAt,
      label: label ?? this.label,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: clearTrimEnd ? null : (trimEnd ?? this.trimEnd),
    );
  }

  @override
  List<Object?> get props => [path, duration, waveform, recordedAt, label, trimStart, trimEnd];
}
