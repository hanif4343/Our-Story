import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/journey_model.dart';

/// Journey metadata lives as a single record under key `'main'`,
/// mirroring `SettingsLocalDataSource`. Falls back to the compiled-in
/// `AppConstants` defaults on first run, so the app always has a valid
/// Journey even before the Creator ever opens the Journey editor.
abstract class JourneyLocalDataSource {
  JourneyModel getJourney();
  Future<void> saveJourney(JourneyModel journey);
}

class JourneyLocalDataSourceImpl implements JourneyLocalDataSource {
  final Box<JourneyModel> box;
  static const String _key = 'main';

  JourneyLocalDataSourceImpl(this.box);

  @override
  JourneyModel getJourney() {
    final existing = box.get(_key);
    if (existing != null) return existing;

    final fresh = JourneyModel(
      title: AppConstants.appName,
      tagline: AppConstants.appTagline,
      startDate: AppConstants.storyStartDate,
      anchorDate: AppConstants.storyAnchorDate,
      partnerOneName: AppConstants.partnerOneName,
      partnerTwoName: AppConstants.partnerTwoName,
      weddingDate: AppConstants.weddingDate,
      featuredName: AppConstants.featuredName,
    );
    box.put(_key, fresh);
    return fresh;
  }

  @override
  Future<void> saveJourney(JourneyModel journey) async {
    await box.put(_key, journey);
  }
}
