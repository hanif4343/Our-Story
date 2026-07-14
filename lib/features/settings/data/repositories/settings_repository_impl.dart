import '../../../../core/errors/failures.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final AuthService authService;

  SettingsRepositoryImpl(this.localDataSource, this.authService);

  @override
  Result<AppSettings> getSettings() {
    try {
      final model = localDataSource.getSettings();
      return Result.success(AppSettings(
        hasCreatorPassword: model.creatorPasswordHash != null,
        hasCompletedFirstSetup: model.hasCompletedFirstSetup,
        defaultMusicPath: model.defaultMusicPath,
        autoPlayMusicInStoryMode: model.autoPlayMusicInStoryMode,
        backgroundMusicVolume: model.backgroundMusicVolume,
      ));
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setCreatorPassword(String plainPassword) async {
    try {
      final model = localDataSource.getSettings();
      model.creatorPasswordHash = authService.hash(plainPassword);
      model.hasCompletedFirstSetup = true;
      await localDataSource.saveSettings(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  @override
  Result<bool> verifyCreatorPassword(String plainPassword) {
    try {
      final model = localDataSource.getSettings();
      if (model.creatorPasswordHash == null) {
        return const Result.failure(AuthFailure('No creator password has been set yet.'));
      }
      final matches = authService.verify(plainPassword, model.creatorPasswordHash!);
      if (!matches) return const Result.failure(AuthFailure());
      return const Result.success(true);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setAutoPlayMusic(bool enabled) async {
    try {
      final model = localDataSource.getSettings();
      model.autoPlayMusicInStoryMode = enabled;
      await localDataSource.saveSettings(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setDefaultMusicPath(String? path) async {
    try {
      final model = localDataSource.getSettings();
      model.defaultMusicPath = path;
      await localDataSource.saveSettings(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setBackgroundMusicVolume(double volume) async {
    try {
      final model = localDataSource.getSettings();
      model.backgroundMusicVolume = volume.clamp(0.0, 1.0);
      await localDataSource.saveSettings(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }
}
