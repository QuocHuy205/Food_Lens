import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileRepositoryImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final docRef = firestore.collection('users').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        final firebaseUser = auth.currentUser;
        if (firebaseUser == null) {
          return Left(AuthFailure(message: 'Bạn chưa đăng nhập'));
        }

        final defaultProfile = UserProfileModel(
          userId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          weight: 70,
          height: 170,
          age: 25,
          gender: 'Male',
          activityLevel: 'Moderate',
          goal: 'Maintain',
          dailyCalorieTarget: _calculateDailyCalorieTarget(
            gender: 'Male',
            weight: 70,
            height: 170,
            age: 25,
            activityLevel: 'Moderate',
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await docRef.set(defaultProfile.toJson(), SetOptions(merge: true));
        return Right(defaultProfile);
      }

      final data = doc.data() ?? <String, dynamic>{};
      final firebaseUser = auth.currentUser;

      // Fill essential fields in case legacy profile data is missing.
      data['userId'] = data['userId'] ?? userId;
      data['email'] = data['email'] ?? firebaseUser?.email ?? '';
      data['name'] = data['name'] ?? firebaseUser?.displayName ?? 'User';
      data['photoUrl'] = data['photoUrl'] ?? firebaseUser?.photoURL;
      data['createdAt'] = data['createdAt'] ?? DateTime.now().toIso8601String();

      final profile = UserProfileModel.fromJson(data);
      final normalizedTarget = _normalizeDailyCalorieTarget(profile);

      if (normalizedTarget != profile.dailyCalorieTarget) {
        final correctedProfile = UserProfileModel(
          userId: profile.userId,
          email: profile.email,
          name: profile.name,
          photoUrl: profile.photoUrl,
          weight: profile.weight,
          height: profile.height,
          age: profile.age,
          gender: profile.gender,
          activityLevel: profile.activityLevel,
          goal: profile.goal,
          dailyCalorieTarget: normalizedTarget,
          createdAt: profile.createdAt,
          updatedAt: DateTime.now(),
        );

        await docRef.set(
          {
            'dailyCalorieTarget': normalizedTarget,
            'updatedAt': correctedProfile.updatedAt?.toIso8601String(),
          },
          SetOptions(merge: true),
        );

        return Right(correctedProfile);
      }

      return Right(profile);
    } on FirebaseException catch (e) {
      return Left(
          DatabaseFailure(message: e.message ?? 'Không tải được hồ sơ'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel(
        userId: profile.userId,
        email: profile.email,
        name: profile.name,
        photoUrl: profile.photoUrl,
        weight: profile.weight,
        height: profile.height,
        age: profile.age,
        gender: profile.gender,
        activityLevel: profile.activityLevel,
        goal: profile.goal,
        dailyCalorieTarget: profile.dailyCalorieTarget,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(profile.userId)
          .set(model.toJson(), SetOptions(merge: true));

      final currentUser = auth.currentUser;
      if (currentUser != null) {
        if ((currentUser.displayName ?? '') != profile.name) {
          await currentUser.updateDisplayName(profile.name);
        }
        if ((currentUser.photoURL ?? '') != (profile.photoUrl ?? '')) {
          await currentUser.updatePhotoURL(profile.photoUrl);
        }
        await currentUser.reload();
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
          DatabaseFailure(message: e.message ?? 'Không cập nhật được hồ sơ'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createProfile(UserProfile profile) async {
    try {
      return updateProfile(profile);
    } on FirebaseException catch (e) {
      return Left(
          DatabaseFailure(message: e.message ?? 'Không tạo được hồ sơ'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  double _calculateDailyCalorieTarget({
    required String gender,
    required double weight,
    required double height,
    required int age,
    required String activityLevel,
  }) {
    final isMale = gender.toLowerCase() == 'male';
    final normalizedActivity = activityLevel.toLowerCase();
    final activityMultiplier = switch (normalizedActivity) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'very active' || 'very_active' => 1.9,
      _ => 1.375,
    };

    final bmr = isMale
        ? 10 * weight + 6.25 * height - 5 * age + 5
        : 10 * weight + 6.25 * height - 5 * age - 161;

    return (bmr * activityMultiplier).roundToDouble();
  }

  double? _normalizeDailyCalorieTarget(UserProfile profile) {
    final savedTarget = profile.dailyCalorieTarget;
    if (savedTarget != null && savedTarget > 0 && savedTarget != 2200) {
      return savedTarget;
    }

    if (profile.weight <= 0 || profile.height <= 0 || profile.age <= 0) {
      return savedTarget;
    }

    return _calculateDailyCalorieTarget(
      gender: profile.gender,
      weight: profile.weight,
      height: profile.height,
      age: profile.age,
      activityLevel: profile.activityLevel,
    );
  }
}
