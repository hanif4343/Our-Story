import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';

/// A themed decorative treatment a scene can opt into — proposal, wedding,
/// pregnancy, baby's birth, family, or anniversary — layered on top of
/// the scene's regular background/animation/letter content (v1.3.0
/// Cinematic Experience Engine). `none` (the default) changes nothing,
/// so every scene authored before v1.3.0 renders exactly as it always
/// has.
@HiveType(typeId: HiveTypeIds.sceneMilestoneType)
enum SceneMilestoneType {
  @HiveField(0)
  none,
  @HiveField(1)
  proposal,
  @HiveField(2)
  wedding,
  @HiveField(3)
  pregnancy,
  @HiveField(4)
  babyBirth,
  @HiveField(5)
  family,
  @HiveField(6)
  anniversary,
}

extension SceneMilestoneTypeX on SceneMilestoneType {
  String get displayName {
    switch (this) {
      case SceneMilestoneType.none:
        return 'None';
      case SceneMilestoneType.proposal:
        return 'Proposal';
      case SceneMilestoneType.wedding:
        return 'Wedding';
      case SceneMilestoneType.pregnancy:
        return 'Pregnancy';
      case SceneMilestoneType.babyBirth:
        return "Baby's Birth";
      case SceneMilestoneType.family:
        return 'Family';
      case SceneMilestoneType.anniversary:
        return 'Anniversary';
    }
  }
}

class SceneMilestoneTypeAdapter extends TypeAdapter<SceneMilestoneType> {
  @override
  final int typeId = HiveTypeIds.sceneMilestoneType;

  @override
  SceneMilestoneType read(BinaryReader reader) => SceneMilestoneType.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, SceneMilestoneType obj) => writer.writeByte(obj.index);
}
