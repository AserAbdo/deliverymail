abstract class Failure {
  final String message;

  const Failure(this.message);
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
