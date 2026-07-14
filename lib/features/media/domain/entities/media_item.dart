import 'package:equatable/equatable.dart';

enum MediaType { photo, video, audio, voiceRecording }

/// A [MediaItem] represents a single local file reference a [Scene]
/// can point to. Only the path is ever persisted (see SceneModel) —
/// this entity is the in-memory shape used while picking/recording,
/// before a path is folded into `Scene.photoPaths` / `videoPaths` /
/// `voiceRecordingPath` / `musicPath`.
class MediaItem extends Equatable {
  final String id;
  final MediaType type;
  final String localPath;
  final String? thumbnailPath;
  final DateTime addedAt;

  const MediaItem({
    required this.id,
    required this.type,
    required this.localPath,
    this.thumbnailPath,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [id, type, localPath, thumbnailPath, addedAt];
}
