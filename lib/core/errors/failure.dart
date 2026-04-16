// Abstract Failure class for error handling
abstract class Failure {
  final String message;

  const Failure(this.message);
}

// Server/Network failures
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

// Firebase failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({required String message}) : super(message);
}

// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}

// Generic failures
class GenericFailure extends Failure {
  const GenericFailure({required String message}) : super(message);
}
