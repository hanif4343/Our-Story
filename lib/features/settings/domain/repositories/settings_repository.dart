import '../../../../core/utils/result.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Result<AppSettings> getSettings();
  Future<Result<void>> setCreatorPassword(String plainPassword);
  Result<bool> verifyCreatorPassword(String plainPassword);
  Future<Result<void>> setAutoPlayMusic(bool enabled);

  /// Sets (or clears, when `null`) the app-wide default background
  /// music used by Story Mode whenever the current scene has no
  /// scene-specific music of its own (v1.4.0 Music Manager).
  Future<Result<void>> setDefaultMusicPath(String? path);

  /// Sets Story Mode's background-music playback volume (0.0–1.0),
  /// applied to both scene-specific and global default music.
  Future<Result<void>> setBackgroundMusicVolume(double volume);
}
