import 'package:equatable/equatable.dart';

/// Domain-level failures. Repositories return `Either<Failure, T>` (dartz),
/// so the presentation layer handles errors without try/catch.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ScanFailure extends Failure {
  const ScanFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
