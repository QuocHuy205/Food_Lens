import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Có thể bỏ nếu không dùng Firestore nữa
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_lens/core/services/api_service.dart'; // Import ApiService mới

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../viewmodels/auth_viewmodel.dart';

// 1. Firebase Auth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// 2. ApiService provider (Dùng để giao tiếp với FastAPI)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// 3. Auth repository provider - CẬP NHẬT TẠI ĐÂY
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final apiService = ref.watch(apiServiceProvider); // Lấy apiService thay vì Firestore

  return AuthRepositoryImpl(
    firebaseAuth: firebaseAuth,
    apiService: apiService, // Truyền apiService vào Repository
  );
});

// --- Các UseCase providers giữ nguyên vì chúng phụ thuộc vào authRepositoryProvider ---

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository: repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository: repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository: repository);
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUseCase(repository: repository);
});

final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleSignInUseCase(repository: repository);
});

// 4. Auth ViewModel provider
final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final forgotPasswordUseCase = ref.watch(forgotPasswordUseCaseProvider);
  final googleSignInUseCase = ref.watch(googleSignInUseCaseProvider);
  final repository = ref.watch(authRepositoryProvider);

  return AuthViewModel(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    googleSignInUseCase: googleSignInUseCase,
    repository: repository,
  );
});