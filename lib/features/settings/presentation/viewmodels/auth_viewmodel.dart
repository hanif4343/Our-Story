import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/settings_repository.dart';

enum AuthStatus { idle, checking, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final bool hasCreatorPassword;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.hasCreatorPassword = false,
  });

  AuthState copyWith({AuthStatus? status, String? errorMessage, bool? hasCreatorPassword}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasCreatorPassword: hasCreatorPassword ?? this.hasCreatorPassword,
    );
  }
}

/// Owns Creator Mode's password gate: first-time setup + subsequent
/// verification. MVVM ViewModel — screens only read [AuthState] and
/// call these methods, never touch the repository directly.
class AuthViewModel extends StateNotifier<AuthState> {
  final SettingsRepository _settingsRepository;

  AuthViewModel(this._settingsRepository) : super(const AuthState()) {
    _loadInitialState();
  }

  void _loadInitialState() {
    final result = _settingsRepository.getSettings();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (settings) => state = state.copyWith(hasCreatorPassword: settings.hasCreatorPassword),
    );
  }

  Future<bool> setPassword(String password) async {
    state = state.copyWith(status: AuthStatus.checking);
    final result = await _settingsRepository.setCreatorPassword(password);
    return result.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.authenticated, hasCreatorPassword: true);
        return true;
      },
    );
  }

  Future<bool> verifyPassword(String password) async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);
    final result = _settingsRepository.verifyCreatorPassword(password);
    return result.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
        return true;
      },
    );
  }

  /// Verifies [currentPassword] before overwriting it with [newPassword] —
  /// used by Settings' "Change Password" action. Returns a human-readable
  /// error via [AuthState.errorMessage] on failure (e.g. wrong current
  /// password) without ever touching Creator Mode's session status.
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

    final verifyResult = _settingsRepository.verifyCreatorPassword(currentPassword);
    if (verifyResult.isFailure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: verifyResult.failureOrNull?.message ?? 'Current password is incorrect.',
      );
      return false;
    }

    final setResult = await _settingsRepository.setCreatorPassword(newPassword);
    return setResult.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
        return true;
      },
    );
  }

  void reset() => state = state.copyWith(status: AuthStatus.idle, errorMessage: null);
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(settingsRepositoryProvider));
});
