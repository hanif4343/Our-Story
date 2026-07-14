import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';

/// App-wide persisted settings: creator auth + light preferences.
/// A single instance lives under key `'main'` in the settings box.
@HiveType(typeId: HiveTypeIds.settingsModel)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String? creatorPasswordHash;

  @HiveField(1)
  bool hasCompletedFirstSetup;

  @HiveField(2)
  String? defaultMusicPath;

  @HiveField(3)
  bool autoPlayMusicInStoryMode;

  @HiveField(4)
  double backgroundMusicVolume;

  SettingsModel({
    this.creatorPasswordHash,
    this.hasCompletedFirstSetup = false,
    this.defaultMusicPath,
    this.autoPlayMusicInStoryMode = true,
    this.backgroundMusicVolume = 0.55,
  });
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = HiveTypeIds.settingsModel;

  @override
  SettingsModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      creatorPasswordHash: fields[0] as String?,
      hasCompletedFirstSetup: fields[1] as bool? ?? false,
      defaultMusicPath: fields[2] as String?,
      autoPlayMusicInStoryMode: fields[3] as bool? ?? true,
      // Field 4 was added in v1.4.0 — falls back gracefully for
      // settings records saved by an older version of the app.
      backgroundMusicVolume: (fields[4] as double?) ?? 0.55,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.creatorPasswordHash)
      ..writeByte(1)
      ..write(obj.hasCompletedFirstSetup)
      ..writeByte(2)
      ..write(obj.defaultMusicPath)
      ..writeByte(3)
      ..write(obj.autoPlayMusicInStoryMode)
      ..writeByte(4)
      ..write(obj.backgroundMusicVolume);
  }
}
