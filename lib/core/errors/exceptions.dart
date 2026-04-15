// Custom exceptions
class ServerException implements Exception {
  final String message;

  ServerException({required this.message});

  @override
  String toString() => message;
}

class FirebaseException implements Exception {
  final String message;

  FirebaseException({required this.message});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException({required this.message});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => message;
}
