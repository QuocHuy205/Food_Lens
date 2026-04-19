import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';

// State for Auth
@immutable
class AuthState {
  final AsyncValue<UserEntity?> user;
  final String? errorMessage;
  final bool isLoading;
  final bool forgotPasswordSuccess;

  const AuthState({
    this.user = const AsyncValue.data(null),
    this.errorMessage,
    this.isLoading = false,
    this.forgotPasswordSuccess = false,
  });

  AuthState copyWith({
    AsyncValue<UserEntity?>? user,
    String? errorMessage,
    bool? isLoading,
    bool? forgotPasswordSuccess,
  }) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      forgotPasswordSuccess:
          forgotPasswordSuccess ?? this.forgotPasswordSuccess,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final AuthRepositoryImpl repository;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
    required this.googleSignInUseCase,
    required this.repository,
  }) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await loginUseCase(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          user: AsyncValue.error(failure.message, StackTrace.current),
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) {
        state = state.copyWith(
          user: AsyncValue.data(user),
          isLoading: false,
        );
      },
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await registerUseCase(email, password, name);

    result.fold(
      (failure) {
        state = state.copyWith(
          user: AsyncValue.error(failure.message, StackTrace.current),
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) {
        state = state.copyWith(
          user: AsyncValue.data(user),
          isLoading: false,
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await googleSignInUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          user: AsyncValue.error(failure.message, StackTrace.current),
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) {
        state = state.copyWith(
          user: AsyncValue.data(user),
          isLoading: false,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (_) {
        state = const AuthState();
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, forgotPasswordSuccess: false);

    final result = await forgotPasswordUseCase(email);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (_) {
        state = state.copyWith(
          forgotPasswordSuccess: true,
          isLoading: false,
        );
      },
    );
  }

  void resetForgotPasswordState() {
    state = state.copyWith(forgotPasswordSuccess: false, errorMessage: null);
  }
}
