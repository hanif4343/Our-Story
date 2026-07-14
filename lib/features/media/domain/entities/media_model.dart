import 'package:equatable/equatable.dart';

enum MediaModelType { photo, video }

/// A structured, ordered view over one of a scene's media paths —
/// derived on demand from `Scene.photoPaths`/`videoPaths` via
/// `Scene.mediaItems`, not persisted separately. Existing storage
/// (`SceneModel.photoPaths`/`videoPaths`) stays exactly as-is; this is
/// purely a richer read-side shape for UI that wants to iterate photos
/// and videos as one ordered, typed list (e.g. a future combined media
/// grid) instead of juggling two raw `List<String>`s.
class MediaModel extends Equatable {
  final String id;
  final MediaModelType type;
  final String path;
  final int order;

  const MediaModel({required this.id, required this.type, required this.path, required this.order});

  @override
  List<Object?> get props => [id, type, path, order];
}
