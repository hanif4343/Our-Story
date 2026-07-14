import 'package:hive/hive.dart';
import '../models/settings_model.dart';

/// Settings live as a single record under key `'main'`.
abstract class SettingsLocalDataSource {
  SettingsModel getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box<SettingsModel> box;
  static const String _key = 'main';

  SettingsLocalDataSourceImpl(this.box);

  @override
  SettingsModel getSettings() {
    final existing = box.get(_key);
    if (existing != null) return existing;
    final fresh = SettingsModel();
    box.put(_key, fresh);
    return fresh;
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    await box.put(_key, settings);
  }
}
