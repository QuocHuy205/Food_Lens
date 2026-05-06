import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:food_lens/core/services/api_service.dart'; // Đảm bảo bạn đã có ApiService
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/auth_token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final ApiService apiService; // Thay thế Firestore bằng ApiService để gọi FastAPI
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.apiService,
  });

  /// Hàm chung để gửi ID Token sang Server FastAPI và lấy UserEntity
  Future<Either<Failure, UserEntity>> _syncWithBackend(User user) async {
    try {
      final idToken = await user.getIdToken();

      // Gửi sang server qua 1 endpoint duy nhất (Register/Login chung)
      final response = await apiService.post('/auth/sync-firebase', data: {
        "idToken": idToken,
      });

      if (response['status'] == 'success') {
        final userData = response['user'];
        final serverAccessToken = response['access_token'];

        // Lưu Access Token của riêng SERVER (dùng cho các API sau này)
        await AuthTokenStorage.save(
          idToken: serverAccessToken,
          uid: userData['uid'].toString(),
          email: userData['email'],
        );

        return Right(UserEntity(
          uid: userData['uid'].toString(),
          email: userData['email'],
          createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
        ));
      } else {
        return Left(AuthFailure(message: response['message'] ?? 'Đồng bộ server thất bại'));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Lỗi kết nối với máy chủ: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      // 1. Xác thực với Firebase
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return Left(FirebaseFailure(message: 'User not found'));

      // 2. Đồng bộ với Backend FastAPI
      return await _syncWithBackend(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: e.message ?? 'Login failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String email, String password, String name) async {
    try {
      // 1. Tạo user trên Firebase
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return Left(FirebaseFailure(message: 'Failed to create user'));

      // 2. Cập nhật Display Name trên Firebase (để server có thể lấy được tên ngay)
      await userCredential.user!.updateDisplayName(name);

      // 3. Đồng bộ với Backend FastAPI
      return await _syncWithBackend(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: e.message ?? 'Registration failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) await _googleSignIn.disconnect();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Left(AuthFailure(message: 'Hủy đăng nhập Google'));

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 1. Đăng nhập Firebase bằng Google Credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) return Left(FirebaseFailure(message: 'Google Sign-In lỗi'));

      // 2. Đồng bộ với Backend FastAPI
      return await _syncWithBackend(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(message: _mapGoogleAuthError(e)));
    } catch (e) {
      return Left(AuthFailure(message: 'Đăng nhập Google thất bại'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      await _googleSignIn.signOut();
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
      if (user == null) return Left(FirebaseFailure(message: 'No user logged in'));

      // Gọi API /auth/me của Server để lấy data mới nhất
      final response = await apiService.get('/auth/me');

      if (response != null) {
        final userData = response['user'];
        return Right(UserEntity(
          uid: userData['uid'].toString(),
          email: userData['email'],
          createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
        ));
      }
      return Left(AuthFailure(message: 'Session expired'));
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to get user'));
    }
  }

  // --- Giữ nguyên forgotPassword và _mapGoogleAuthError ---
  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(message: 'Lỗi gửi email khôi phục'));
    }
  }

  String _mapGoogleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed': return 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
      default: return e.message ?? 'Đăng nhập Google thất bại.';
    }
  }
}