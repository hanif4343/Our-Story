import 'package:equatable/equatable.dart';

/// Base failure type returned to the presentation layer.
/// Keeps UI code free of raw exceptions (Clean Architecture boundary).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'A local storage error occurred.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Incorrect password.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something unexpected happened.']);
}
