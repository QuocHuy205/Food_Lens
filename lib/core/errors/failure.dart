// Abstract Failure class for error handling
abstract class Failure {
  final String message;

  Failure({required this.message});
}

// Server/Network failures
class ServerFailure extends Failure {
  ServerFailure({required super.message});
}

// Firebase failures
class FirebaseFailure extends Failure {
  FirebaseFailure({required super.message});
}

// Validation failures
class ValidationFailure extends Failure {
  ValidationFailure({required super.message});
}

// Cache failures
class CacheFailure extends Failure {
  CacheFailure({required super.message});
}

// Generic failures
class GenericFailure extends Failure {
  GenericFailure({required super.message});
}
