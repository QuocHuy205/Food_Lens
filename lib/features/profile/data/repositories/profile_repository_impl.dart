import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      // TODO: Fetch from Firestore
      return Left(ServerFailure(message: 'Not implemented'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    try {
      // TODO: Update Firestore
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createProfile(UserProfile profile) async {
    try {
      // TODO: Save to Firestore
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
