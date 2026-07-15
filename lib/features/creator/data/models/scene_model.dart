import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../../../animation/domain/animation_type.dart';
import '../../../media/data/models/voice_model.dart';
import '../../domain/entities/background_type.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_milestone_type.dart';
import '../../domain/entities/transition_type.dart';
import 'letter_model.dart';

/// Hive persistence model for a [Scene]. Mirrors the domain entity's
/// shape but is annotated for storage — the data layer converts to/from
/// [Scene] via [toEntity] / [fromEntity], keeping Hive fully out of
/// domain & presentation.
@HiveType(typeId: HiveTypeIds.sceneModel)
class SceneModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int order;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String storyText;

  @HiveField(5)
  List<String> photoPaths;

  @HiveField(6)
  List<String> videoPaths;

  @HiveField(7)
  String? voiceRecordingPath;

  @HiveField(8)
  String? musicPath;

  @HiveField(9)
  AnimationType animationType;

  @HiveField(10)
  TransitionType transitionType;

  @HiveField(11)
  BackgroundType backgroundType;

  @HiveField(12)
  String? backgroundColorHex;

  @HiveField(13)
  int displayDurationMs;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  String subtitle;

  @HiveField(17)
  int year;

  @HiveField(18)
  String chapter;

  @HiveField(19)
  bool isFavorite;

  @HiveField(20)
  List<String> tags;

  @HiveField(21)
  LetterModel? letter;

  @HiveField(22)
  VoiceModel? voiceNote;

  @HiveField(23)
  String? chapterId;

  @HiveField(24)
  SceneMilestoneType milestoneType;

  /// Non-destructive trim range for [musicPath] (v1.6.0 Audio Trim
  /// Editor). `musicTrimEndMs` of `null` means "no end trim".
  @HiveField(25)
  int musicTrimStartMs;

  @HiveField(26)
  int? musicTrimEndMs;

  SceneModel({
    required this.id,
    required this.order,
    required this.title,
    this.subtitle = '',
    required this.date,
    int? year,
    this.chapter = '',
    this.chapterId,
    required this.storyText,
    this.letter,
    this.photoPaths = const [],
    this.videoPaths = const [],
    this.voiceRecordingPath,
    this.voiceNote,
    this.musicPath,
    this.musicTrimStartMs = 0,
    this.musicTrimEndMs,
    this.animationType = AnimationType.none,
    this.transitionType = TransitionType.fade,
    this.backgroundType = BackgroundType.romanticGradient,
    this.backgroundColorHex,
    this.displayDurationMs = 8000,
    this.isFavorite = false,
    this.tags = const [],
    this.milestoneType = SceneMilestoneType.none,
    required this.createdAt,
    required this.updatedAt,
  }) : year = year ?? date.year;

  factory SceneModel.fromEntity(Scene scene) {
    return SceneModel(
      id: scene.id,
      order: scene.order,
      title: scene.title,
      subtitle: scene.subtitle,
      date: scene.date,
      year: scene.year,
      chapter: scene.chapter,
      chapterId: scene.chapterId,
      storyText: scene.storyText,
      letter: scene.letter != null ? LetterModel.fromEntity(scene.letter!) : null,
      photoPaths: scene.photoPaths,
      videoPaths: scene.videoPaths,
      voiceRecordingPath: scene.voiceRecordingPath,
      voiceNote: scene.voiceNote != null ? VoiceModel.fromEntity(scene.voiceNote!) : null,
      musicPath: scene.musicPath,
      musicTrimStartMs: scene.musicTrimStart.inMilliseconds,
      musicTrimEndMs: scene.musicTrimEnd?.inMilliseconds,
      animationType: scene.animationType,
      transitionType: scene.transitionType,
      backgroundType: scene.backgroundType,
      backgroundColorHex: scene.backgroundColorHex,
      displayDurationMs: scene.displayDuration.inMilliseconds,
      isFavorite: scene.isFavorite,
      tags: scene.tags,
      milestoneType: scene.milestoneType,
      createdAt: scene.createdAt,
      updatedAt: scene.updatedAt,
    );
  }

  Scene toEntity() {
    return Scene(
      id: id,
      order: order,
      title: title,
      subtitle: subtitle,
      date: date,
      year: year,
      chapter: chapter,
      chapterId: chapterId,
      storyText: storyText,
      letter: letter?.toEntity(),
      photoPaths: photoPaths,
      videoPaths: videoPaths,
      voiceRecordingPath: voiceRecordingPath,
      voiceNote: voiceNote?.toEntity(),
      musicPath: musicPath,
      musicTrimStart: Duration(milliseconds: musicTrimStartMs),
      musicTrimEnd: musicTrimEndMs != null ? Duration(milliseconds: musicTrimEndMs!) : null,
      animationType: animationType,
      transitionType: transitionType,
      backgroundType: backgroundType,
      backgroundColorHex: backgroundColorHex,
      displayDuration: Duration(milliseconds: displayDurationMs),
      isFavorite: isFavorite,
      tags: tags,
      milestoneType: milestoneType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Hand-written Hive TypeAdapter (no build_runner dependency needed to
/// compile this foundation project).
class SceneModelAdapter extends TypeAdapter<SceneModel> {
  @override
  final int typeId = HiveTypeIds.sceneModel;

  @override
  SceneModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    final date = fields[3] as DateTime;
    return SceneModel(
      id: fields[0] as String,
      order: fields[1] as int,
      title: fields[2] as String,
      date: date,
      storyText: fields[4] as String,
      photoPaths: (fields[5] as List).cast<String>(),
      videoPaths: (fields[6] as List).cast<String>(),
      voiceRecordingPath: fields[7] as String?,
      musicPath: fields[8] as String?,
      animationType: fields[9] as AnimationType,
      transitionType: fields[10] as TransitionType,
      backgroundType: fields[11] as BackgroundType,
      backgroundColorHex: fields[12] as String?,
      displayDurationMs: fields[13] as int,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      // Fields 16-20 were added in v1.1.0; 21-23 in v1.2.0. Falling back
      // gracefully for every one of them means a scene written by an
      // older version of the app still loads without error — no manual
      // migration step required, ever.
      subtitle: (fields[16] as String?) ?? '',
      year: (fields[17] as int?) ?? date.year,
      chapter: (fields[18] as String?) ?? '',
      isFavorite: (fields[19] as bool?) ?? false,
      tags: fields[20] != null ? (fields[20] as List).cast<String>() : const [],
      letter: fields[21] as LetterModel?,
      voiceNote: fields[22] as VoiceModel?,
      chapterId: fields[23] as String?,
      // Field 24 was added in v1.3.0.
      milestoneType: (fields[24] as SceneMilestoneType?) ?? SceneMilestoneType.none,
      // Fields 25-26 were added in v1.6.0 (Audio Trim Editor) — missing
      // on older records means "untrimmed", i.e. play the whole track.
      musicTrimStartMs: (fields[25] as int?) ?? 0,
      musicTrimEndMs: fields[26] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SceneModel obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.order)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.storyText)
      ..writeByte(5)
      ..write(obj.photoPaths)
      ..writeByte(6)
      ..write(obj.videoPaths)
      ..writeByte(7)
      ..write(obj.voiceRecordingPath)
      ..writeByte(8)
      ..write(obj.musicPath)
      ..writeByte(9)
      ..write(obj.animationType)
      ..writeByte(10)
      ..write(obj.transitionType)
      ..writeByte(11)
      ..write(obj.backgroundType)
      ..writeByte(12)
      ..write(obj.backgroundColorHex)
      ..writeByte(13)
      ..write(obj.displayDurationMs)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.subtitle)
      ..writeByte(17)
      ..write(obj.year)
      ..writeByte(18)
      ..write(obj.chapter)
      ..writeByte(19)
      ..write(obj.isFavorite)
      ..writeByte(20)
      ..write(obj.tags)
      ..writeByte(21)
      ..write(obj.letter)
      ..writeByte(22)
      ..write(obj.voiceNote)
      ..writeByte(23)
      ..write(obj.chapterId)
      ..writeByte(24)
      ..write(obj.milestoneType)
      ..writeByte(25)
      ..write(obj.musicTrimStartMs)
      ..writeByte(26)
      ..write(obj.musicTrimEndMs);
  }
}
