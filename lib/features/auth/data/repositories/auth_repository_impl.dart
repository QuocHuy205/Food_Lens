import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/auth_token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

      final idToken = await user.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        await AuthTokenStorage.save(
          idToken: idToken,
          refreshToken: user.refreshToken,
          uid: user.uid,
          email: user.email,
        );
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

      final idToken = await user.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        await AuthTokenStorage.save(
          idToken: idToken,
          refreshToken: user.refreshToken,
          uid: user.uid,
          email: user.email,
        );
      }

      await _upsertUserDocument(user, name: name);

      final userEntity = UserEntity(
        uid: user.uid,
        email: user.email!,
        createdAt: DateTime.now(),
      );

      return Right(userEntity);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: e.message ?? 'Registration failed'));
    } on FirebaseException catch (e) {
      return Left(
          DatabaseFailure(message: e.message ?? 'Firestore write failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return Left(AuthFailure(message: 'Bạn đã hủy đăng nhập Google'));
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        return Left(
          AuthFailure(
            message:
                'Không lấy được token Google. Kiểm tra SHA-1/SHA-256 và tải lại google-services.json.',
          ),
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null || user.email == null) {
        return Left(FirebaseFailure(
            message: 'Không lấy được thông tin tài khoản Google'));
      }

      final idToken = await user.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        await AuthTokenStorage.save(
          idToken: idToken,
          refreshToken: user.refreshToken,
          uid: user.uid,
          email: user.email,
        );
      }

      await _upsertUserDocument(
        user,
        name: user.displayName,
      );

      return Right(
        UserEntity(
          uid: user.uid,
          email: user.email!,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: _mapGoogleAuthError(e)));
    } on PlatformException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('10') ||
          msg.contains('developer_error') ||
          msg.contains('api exception 10')) {
        return Left(
          AuthFailure(
            message:
                'Google Sign-In lỗi cấu hình Android (DEVELOPER_ERROR 10). Thêm SHA-1/SHA-256 vào Firebase rồi tải lại google-services.json.',
          ),
        );
      }

      return Left(
        AuthFailure(
          message: e.message ?? 'Google Sign-In thất bại. Vui lòng thử lại.',
        ),
      );
    } on FirebaseException catch (e) {
      return Left(
          DatabaseFailure(message: e.message ?? 'Firestore write failed'));
    } catch (_) {
      return Left(
          AuthFailure(message: 'Không thể đăng nhập Google. Vui lòng thử lại'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      await AuthTokenStorage.clear();
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

      final freshIdToken = await user.getIdToken(true);
      if (freshIdToken != null && freshIdToken.isNotEmpty) {
        await AuthTokenStorage.save(
          idToken: freshIdToken,
          refreshToken: user.refreshToken,
          uid: user.uid,
          email: user.email,
        );
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

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
          FirebaseFailure(message: e.message ?? 'Failed to send reset email'));
    } catch (e) {
      return Left(FirebaseFailure(message: 'Failed to send reset email'));
    }
  }

  Future<void> _upsertUserDocument(User user, {String? name}) async {
    await firebaseFirestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'photoUrl': user.photoURL,
        'updatedAt': DateTime.now().toIso8601String(),
        'createdAt': user.metadata.creationTime?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  String _mapGoogleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Google provider chưa bật trong Firebase Authentication.';
      case 'invalid-credential':
        return 'Credential Google không hợp lệ. Kiểm tra SHA và google-services.json.';
      case 'account-exists-with-different-credential':
        return 'Email này đã tồn tại với phương thức đăng nhập khác.';
      case 'network-request-failed':
        return 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return e.message ?? 'Đăng nhập Google thất bại.';
    }
  }
}
