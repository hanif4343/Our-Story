# Media (v1.1.0 — Implemented)

Real, working implementations of the picker/recorder/thumbnail/cache
pipeline that were architecture-only placeholders in v1.0.0 Foundation.

- `ImagePickerService` — `image_picker` gallery/camera photo picking
- `VideoPickerService` — `image_picker` gallery/camera video picking
  (capped at 3 minutes to keep Story Mode moments-sized)
- `AudioRecorderService` — `record` package voice narration capture,
  with `permission_handler`-backed microphone permission handling
- `ThumbnailService` — `video_thumbnail` JPEG thumbnail generation
- `MediaCacheService` — in-memory existence-check cache to avoid
  redundant disk I/O when re-rendering the same scene
- `MediaStorageService` — every picked/recorded file is copied into a
  permanent app-owned directory (`our_story_media/` under the app's
  documents directory) before its path is ever written into a `Scene`,
  since picker/recorder temp paths are not guaranteed to survive an OS
  cache clear.

All of the above are wired into Riverpod via
`features/media/presentation/providers/media_providers.dart` and
consumed by the Creator Mode scene editor
(`MediaPickerSection`, `VideoPickerSection`, `MusicSelector`,
`VoiceRecorderWidget`).

Scenes still only ever store local file-system **paths**
(`Scene.photoPaths`, `videoPaths`, `voiceRecordingPath`, `musicPath`) —
this feature never introduces network or cloud storage, keeping the
whole app fully offline.
