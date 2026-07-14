import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/letter.dart';

/// Hive-persisted mirror of [Letter], embedded directly inside
/// [SceneModel] (not stored in its own box — a letter has no identity
/// or lifecycle independent of its scene).
@HiveType(typeId: HiveTypeIds.letterModel)
class LetterModel {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? subtitle;

  @HiveField(2)
  String longLetter;

  @HiveField(3)
  String? quote;

  @HiveField(4)
  List<String> highlightedWords;

  @HiveField(5)
  bool typingAnimationEnabled;

  @HiveField(6)
  bool envelopeAnimationEnabled;

  LetterModel({
    this.title,
    this.subtitle,
    this.longLetter = '',
    this.quote,
    this.highlightedWords = const [],
    this.typingAnimationEnabled = true,
    this.envelopeAnimationEnabled = true,
  });

  factory LetterModel.fromEntity(Letter letter) => LetterModel(
        title: letter.title,
        subtitle: letter.subtitle,
        longLetter: letter.longLetter,
        quote: letter.quote,
        highlightedWords: letter.highlightedWords,
        typingAnimationEnabled: letter.typingAnimationEnabled,
        envelopeAnimationEnabled: letter.envelopeAnimationEnabled,
      );

  Letter toEntity() => Letter(
        title: title,
        subtitle: subtitle,
        longLetter: longLetter,
        quote: quote,
        highlightedWords: highlightedWords,
        typingAnimationEnabled: typingAnimationEnabled,
        envelopeAnimationEnabled: envelopeAnimationEnabled,
      );
}

class LetterModelAdapter extends TypeAdapter<LetterModel> {
  @override
  final int typeId = HiveTypeIds.letterModel;

  @override
  LetterModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return LetterModel(
      title: fields[0] as String?,
      subtitle: fields[1] as String?,
      longLetter: (fields[2] as String?) ?? '',
      quote: fields[3] as String?,
      highlightedWords: fields[4] != null ? (fields[4] as List).cast<String>() : const [],
      typingAnimationEnabled: (fields[5] as bool?) ?? true,
      envelopeAnimationEnabled: (fields[6] as bool?) ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, LetterModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.longLetter)
      ..writeByte(3)
      ..write(obj.quote)
      ..writeByte(4)
      ..write(obj.highlightedWords)
      ..writeByte(5)
      ..write(obj.typingAnimationEnabled)
      ..writeByte(6)
      ..write(obj.envelopeAnimationEnabled);
  }
}
