import '../../../../core/utils/result.dart';
import '../entities/journey.dart';

abstract class JourneyRepository {
  Result<Journey> getJourney();
  Future<Result<void>> saveJourney(Journey journey);
}
