import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}
