import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';

/// Cross-scene transition styles selectable in Creator Mode and rendered
/// automatically in Story Mode.
@HiveType(typeId: HiveTypeIds.transitionType)
enum TransitionType {
  @HiveField(0)
  fade,
  @HiveField(1)
  slideLeft,
  @HiveField(2)
  slideUp,
  @HiveField(3)
  zoomIn,
  @HiveField(4)
  crossDissolve,
  @HiveField(5)
  slideRight,
  @HiveField(6)
  slideDown,
  @HiveField(7)
  blur,
  @HiveField(8)
  parallax,
  @HiveField(9)
  pageCurl,
  @HiveField(10)
  lightFlash,
  // v1.5.0 Advanced Scene Transitions:
  @HiveField(11)
  dreamFade,
  @HiveField(12)
  romanticBlur,
  @HiveField(13)
  heartReveal,
  @HiveField(14)
  roseBloom,
  @HiveField(15)
  goldenFlash,
  @HiveField(16)
  filmBurn,
  @HiveField(17)
  softZoom,
}

extension TransitionTypeX on TransitionType {
  String get displayName {
    switch (this) {
      case TransitionType.fade:
        return 'Fade';
      case TransitionType.slideLeft:
        return 'Slide Left';
      case TransitionType.slideUp:
        return 'Slide Up';
      case TransitionType.zoomIn:
        return 'Zoom';
      case TransitionType.crossDissolve:
        return 'Cross Fade';
      case TransitionType.slideRight:
        return 'Slide Right';
      case TransitionType.slideDown:
        return 'Slide Down';
      case TransitionType.blur:
        return 'Blur';
      case TransitionType.parallax:
        return 'Parallax';
      case TransitionType.pageCurl:
        return 'Page Curl';
      case TransitionType.lightFlash:
        return 'Light Flash';
      case TransitionType.dreamFade:
        return 'Dream Fade';
      case TransitionType.romanticBlur:
        return 'Romantic Blur';
      case TransitionType.heartReveal:
        return 'Heart Reveal';
      case TransitionType.roseBloom:
        return 'Rose Bloom';
      case TransitionType.goldenFlash:
        return 'Golden Flash';
      case TransitionType.filmBurn:
        return 'Film Burn';
      case TransitionType.softZoom:
        return 'Soft Zoom';
    }
  }
}

class TransitionTypeAdapter extends TypeAdapter<TransitionType> {
  @override
  final int typeId = HiveTypeIds.transitionType;

  @override
  TransitionType read(BinaryReader reader) => TransitionType.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, TransitionType obj) => writer.writeByte(obj.index);
}
