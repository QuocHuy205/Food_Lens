import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  Future<Either<Failure, UserProfile>> call(String userId) async {
    return await repository.getProfile(userId);
  }
}
