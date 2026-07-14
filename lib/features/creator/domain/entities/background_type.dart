import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';

/// What renders behind a scene's content in Story Mode.
@HiveType(typeId: HiveTypeIds.backgroundType)
enum BackgroundType {
  @HiveField(0)
  romanticGradient,
  @HiveField(1)
  solidColor,
  @HiveField(2)
  photo,
  @HiveField(3)
  video,
}

extension BackgroundTypeX on BackgroundType {
  String get displayName {
    switch (this) {
      case BackgroundType.romanticGradient:
        return 'Romantic Gradient';
      case BackgroundType.solidColor:
        return 'Solid Color';
      case BackgroundType.photo:
        return 'Photo';
      case BackgroundType.video:
        return 'Video';
    }
  }
}

class BackgroundTypeAdapter extends TypeAdapter<BackgroundType> {
  @override
  final int typeId = HiveTypeIds.backgroundType;

  @override
  BackgroundType read(BinaryReader reader) => BackgroundType.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, BackgroundType obj) => writer.writeByte(obj.index);
}
