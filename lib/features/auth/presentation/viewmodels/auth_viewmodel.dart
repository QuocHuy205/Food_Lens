import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../../core/errors/failure.dart';

// State for Auth
@immutable
class AuthState {
  final AsyncValue<UserEntity?> user;
  final String? errorMessage;

  const AuthState({
    this.user = const AsyncValue.data(null),
    this.errorMessage,
  });

  AuthState copyWith({
    AsyncValue<UserEntity?>? user,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// TODO: Implement with Riverpod generator once auth dependencies are set up
// For now, placeholder:
class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(user: const AsyncValue.loading());
    // TODO: Call LoginUseCase
    // final result = await _loginUseCase(email, password);
    // result.fold(
    //   (failure) => state = state.copyWith(
    //     user: AsyncValue.error(failure.message, StackTrace.current),
    //     errorMessage: failure.message,
    //   ),
    //   (user) => state = state.copyWith(user: AsyncValue.data(user)),
    // );
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(user: const AsyncValue.loading());
    // TODO: Call RegisterUseCase
  }

  Future<void> logout() async {
    // TODO: Call LogoutUseCase
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
