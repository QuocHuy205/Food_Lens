import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(FirebaseFailure(message: 'User not found'));
      }

      final userEntity = UserEntity(
        uid: user.uid,
        email: user.email!,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );

      return Right(userEntity);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: e.message ?? 'Login failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
      String email, String password, String name) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(FirebaseFailure(message: 'Failed to create user'));
      }

      // Save user data to Firestore
      await firebaseFirestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final userEntity = UserEntity(
        uid: user.uid,
        email: user.email!,
        createdAt: DateTime.now(),
      );

      return Right(userEntity);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: e.message ?? 'Registration failed'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(message: 'Logout failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(FirebaseFailure(message: 'No user logged in'));
      }

      final userEntity = UserEntity(
        uid: user.uid,
        email: user.email!,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );

      return Right(userEntity);
    } catch (e) {
      return Left(FirebaseFailure(message: 'Failed to get current user'));
    }
  }
}
