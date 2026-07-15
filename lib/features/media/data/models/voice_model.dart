import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/voice_note.dart';

/// Hive-persisted mirror of [VoiceNote], embedded directly inside
/// [SceneModel] — a voice note has no identity or lifecycle independent
/// of its scene, so (like [LetterModel]) it isn't stored in its own box.
@HiveType(typeId: HiveTypeIds.voiceModel)
class VoiceModel {
  @HiveField(0)
  String path;

  @HiveField(1)
  int durationMs;

  @HiveField(2)
  List<double> waveform;

  @HiveField(3)
  DateTime recordedAt;

  @HiveField(4)
  String label;

  /// Non-destructive trim range (v1.6.0 Audio Trim Editor). `trimEndMs`
  /// of `null` means "no end trim — play to the natural end".
  @HiveField(5)
  int trimStartMs;

  @HiveField(6)
  int? trimEndMs;

  VoiceModel({
    required this.path,
    required this.durationMs,
    this.waveform = const [],
    required this.recordedAt,
    this.label = '',
    this.trimStartMs = 0,
    this.trimEndMs,
  });

  factory VoiceModel.fromEntity(VoiceNote note) => VoiceModel(
        path: note.path,
        durationMs: note.duration.inMilliseconds,
        waveform: note.waveform,
        recordedAt: note.recordedAt,
        label: note.label,
        trimStartMs: note.trimStart.inMilliseconds,
        trimEndMs: note.trimEnd?.inMilliseconds,
      );

  VoiceNote toEntity() => VoiceNote(
        path: path,
        duration: Duration(milliseconds: durationMs),
        waveform: waveform,
        recordedAt: recordedAt,
        label: label,
        trimStart: Duration(milliseconds: trimStartMs),
        trimEnd: trimEndMs != null ? Duration(milliseconds: trimEndMs!) : null,
      );
}

class VoiceModelAdapter extends TypeAdapter<VoiceModel> {
  @override
  final int typeId = HiveTypeIds.voiceModel;

  @override
  VoiceModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return VoiceModel(
      path: fields[0] as String,
      durationMs: (fields[1] as int?) ?? 0,
      waveform: fields[2] != null ? (fields[2] as List).cast<double>() : const [],
      recordedAt: fields[3] as DateTime,
      // Field 4 was added in v1.4.0 — missing on older records (falls
      // back to an empty/unnamed label, no migration step needed).
      label: (fields[4] as String?) ?? '',
      // Fields 5-6 were added in v1.6.0 (Audio Trim Editor) — missing on
      // older records means "untrimmed", i.e. play the whole recording.
      trimStartMs: (fields[5] as int?) ?? 0,
      trimEndMs: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VoiceModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.durationMs)
      ..writeByte(2)
      ..write(obj.waveform)
      ..writeByte(3)
      ..write(obj.recordedAt)
      ..writeByte(4)
      ..write(obj.label)
      ..writeByte(5)
      ..write(obj.trimStartMs)
      ..writeByte(6)
      ..write(obj.trimEndMs);
  }
}
