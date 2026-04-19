import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase({required this.repository});

  Future<Either<Failure, void>> call(UserProfile profile) async {
    return repository.createProfile(profile);
  }
}
