import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/chapter.dart';

/// Hive persistence model for a [Chapter], stored in its own
/// `chapters_box` — mirrors the `Scene`/`SceneModel` split established
/// in v1.0.0/v1.1.0.
@HiveType(typeId: HiveTypeIds.chapterModel)
class ChapterModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  int order;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  ChapterModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterModel.fromEntity(Chapter chapter) => ChapterModel(
        id: chapter.id,
        title: chapter.title,
        subtitle: chapter.subtitle,
        order: chapter.order,
        createdAt: chapter.createdAt,
        updatedAt: chapter.updatedAt,
      );

  Chapter toEntity() => Chapter(
        id: id,
        title: title,
        subtitle: subtitle,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class ChapterModelAdapter extends TypeAdapter<ChapterModel> {
  @override
  final int typeId = HiveTypeIds.chapterModel;

  @override
  ChapterModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterModel(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: (fields[2] as String?) ?? '',
      order: fields[3] as int,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }
}
