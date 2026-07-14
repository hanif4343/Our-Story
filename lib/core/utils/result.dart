import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// A lightweight Either-style result wrapper so use cases never throw
/// across the domain boundary. Avoids pulling in a full fp library
/// while keeping the same safety guarantees.
abstract class Result<T> extends Equatable {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  Failure? get failureOrNull => this is Error<T> ? (this as Error<T>).failure : null;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.data);
    if (self is Error<T>) return onFailure(self.failure);
    throw StateError('Unreachable Result state');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}
