import 'package:equatable/equatable.dart';
import '../../../creator/domain/entities/scene.dart';

/// Lightweight projection of a [Scene] for timeline UI (e.g. Creator
/// Mode's reorderable list, or a future mini-map scrubber in Story Mode).
class TimelineEntry extends Equatable {
  final String sceneId;
  final int order;
  final String title;
  final DateTime date;
  final String? thumbnailPath;

  const TimelineEntry({
    required this.sceneId,
    required this.order,
    required this.title,
    required this.date,
    this.thumbnailPath,
  });

  factory TimelineEntry.fromScene(Scene scene) => TimelineEntry(
        sceneId: scene.id,
        order: scene.order,
        title: scene.title,
        date: scene.date,
        thumbnailPath: scene.photoPaths.isNotEmpty ? scene.photoPaths.first : null,
      );

  @override
  List<Object?> get props => [sceneId, order, title, date, thumbnailPath];
}
