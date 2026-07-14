import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/journey.dart';
import '../../domain/repositories/journey_repository.dart';
import '../datasources/journey_local_datasource.dart';
import '../models/journey_model.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final JourneyLocalDataSource localDataSource;
  JourneyRepositoryImpl(this.localDataSource);

  @override
  Result<Journey> getJourney() {
    try {
      return Result.success(localDataSource.getJourney().toEntity());
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveJourney(Journey journey) async {
    try {
      await localDataSource.saveJourney(JourneyModel.fromEntity(journey));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }
}
