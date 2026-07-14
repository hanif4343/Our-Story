import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/journey.dart';
import '../../domain/repositories/journey_repository.dart';

/// Owns the single, editable Journey record (title, tagline, start/anchor
/// dates) — the top of the Journey → Chapter → Scene hierarchy. Starts
/// `null` until the first load completes; the repository itself always
/// falls back to `AppConstants` defaults on first run, so `state` only
/// stays `null` for the brief moment before that initial read finishes.
class JourneyViewModel extends StateNotifier<Journey?> {
  final JourneyRepository _repository;

  JourneyViewModel(this._repository) : super(null) {
    _load();
  }

  void _load() {
    final result = _repository.getJourney();
    result.fold((_) {}, (journey) => state = journey);
  }

  Future<bool> update(Journey journey) async {
    final result = await _repository.saveJourney(journey);
    return result.fold(
      (_) => false,
      (_) {
        state = journey;
        return true;
      },
    );
  }
}

final journeyViewModelProvider = StateNotifierProvider<JourneyViewModel, Journey?>((ref) {
  return JourneyViewModel(ref.watch(journeyRepositoryProvider));
});
