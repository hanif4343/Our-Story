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

  const VoiceNote({
    required this.path,
    required this.duration,
    this.waveform = const [],
    required this.recordedAt,
    this.label = '',
  });

  VoiceNote copyWith({
    String? path,
    Duration? duration,
    List<double>? waveform,
    DateTime? recordedAt,
    String? label,
  }) {
    return VoiceNote(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      waveform: waveform ?? this.waveform,
      recordedAt: recordedAt ?? this.recordedAt,
      label: label ?? this.label,
    );
  }

  @override
  List<Object?> get props => [path, duration, waveform, recordedAt, label];
}
