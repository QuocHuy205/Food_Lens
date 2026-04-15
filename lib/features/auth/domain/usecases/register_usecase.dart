import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call(
      String email, String password, String name) async {
    return await repository.register(email, password, name);
  }
}
