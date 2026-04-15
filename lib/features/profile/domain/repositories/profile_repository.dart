import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile(String userId);
  Future<Either<Failure, void>> updateProfile(UserProfile profile);
  Future<Either<Failure, void>> createProfile(UserProfile profile);
}
