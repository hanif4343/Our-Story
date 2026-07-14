import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsViewModel extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsViewModel(this._repository) : super(AppSettings.initial()) {
    _load();
  }

  void _load() {
    final result = _repository.getSettings();
    result.fold((_) {}, (settings) => state = settings);
  }

  Future<void> toggleAutoPlayMusic(bool enabled) async {
    await _repository.setAutoPlayMusic(enabled);
    _load();
  }

  /// Sets (or clears, when `null`) the app-wide default background
  /// music (v1.4.0 Music Manager).
  Future<void> setDefaultMusicPath(String? path) async {
    await _repository.setDefaultMusicPath(path);
    _load();
  }

  /// Sets Story Mode's background-music volume (0.0–1.0).
  Future<void> setBackgroundMusicVolume(double volume) async {
    await _repository.setBackgroundMusicVolume(volume);
    _load();
  }
}

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, AppSettings>((ref) {
  return SettingsViewModel(ref.watch(settingsRepositoryProvider));
});
