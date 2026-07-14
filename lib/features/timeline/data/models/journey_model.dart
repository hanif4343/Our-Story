import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/journey.dart';

/// Hive persistence model for [Journey]. A single record lives under
/// key `'main'` in `journey_box` — mirrors the `SettingsModel` singleton
/// pattern.
@HiveType(typeId: HiveTypeIds.journeyModel)
class JourneyModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String tagline;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  DateTime anchorDate;

  @HiveField(4)
  String description;

  @HiveField(5)
  String partnerOneName;

  @HiveField(6)
  String partnerTwoName;

  @HiveField(7)
  DateTime? weddingDate;

  @HiveField(8)
  String featuredName;

  JourneyModel({
    required this.title,
    required this.tagline,
    required this.startDate,
    required this.anchorDate,
    this.description = '',
    this.partnerOneName = '',
    this.partnerTwoName = '',
    this.weddingDate,
    this.featuredName = '',
  });

  factory JourneyModel.fromEntity(Journey journey) => JourneyModel(
        title: journey.title,
        tagline: journey.tagline,
        startDate: journey.startDate,
        anchorDate: journey.anchorDate,
        description: journey.description,
        partnerOneName: journey.partnerOneName,
        partnerTwoName: journey.partnerTwoName,
        weddingDate: journey.weddingDate,
        featuredName: journey.featuredName,
      );

  Journey toEntity() => Journey(
        title: title,
        tagline: tagline,
        startDate: startDate,
        anchorDate: anchorDate,
        description: description,
        partnerOneName: partnerOneName,
        partnerTwoName: partnerTwoName,
        weddingDate: weddingDate,
        featuredName: featuredName,
      );
}

class JourneyModelAdapter extends TypeAdapter<JourneyModel> {
  @override
  final int typeId = HiveTypeIds.journeyModel;

  @override
  JourneyModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return JourneyModel(
      title: fields[0] as String,
      tagline: fields[1] as String,
      startDate: fields[2] as DateTime,
      anchorDate: fields[3] as DateTime,
      description: (fields[4] as String?) ?? '',
      // Fields 5-7 were added in v1.3.0, field 8 in v1.5.0. Missing
      // values (records saved by an older version of the app) fall
      // back gracefully — no migration step, ever.
      partnerOneName: (fields[5] as String?) ?? '',
      partnerTwoName: (fields[6] as String?) ?? '',
      weddingDate: fields[7] as DateTime?,
      featuredName: (fields[8] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, JourneyModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.tagline)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.anchorDate)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.partnerOneName)
      ..writeByte(6)
      ..write(obj.partnerTwoName)
      ..writeByte(7)
      ..write(obj.weddingDate)
      ..writeByte(8)
      ..write(obj.featuredName);
  }
}
