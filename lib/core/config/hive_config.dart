/// Documents the Hive storage contract for this project.
///
/// Actual adapter registration and box lifecycle live in
/// `core/services/local_storage_service.dart` — this file exists purely
/// so the `core/config` layer clearly enumerates *what* is persisted and
/// *why*, independent of *how*.
///
/// Persisted boxes:
/// - `scenes_box`    -> List of [SceneModel], the full story timeline.
/// - `settings_box`  -> Single [SettingsModel] (creator password hash,
///                      last-opened state, preferences).
///
/// Media (photos/videos/audio/voice recordings) is NOT stored inside Hive
/// itself — only the local file-system paths are. Hive stores metadata,
/// the OS file system stores the bytes. See `features/media`.
class HiveConfig {
  HiveConfig._();
}
