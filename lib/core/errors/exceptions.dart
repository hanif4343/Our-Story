/// Thrown by the data layer (datasources). Caught by repositories and
/// mapped to a [Failure] before reaching domain/presentation.
class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'A local storage error occurred.']);

  @override
  String toString() => 'StorageException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'The requested item was not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Incorrect password.']);

  @override
  String toString() => 'AuthException: $message';
}
