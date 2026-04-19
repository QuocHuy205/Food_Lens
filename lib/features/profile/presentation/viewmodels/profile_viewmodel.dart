import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

@immutable
class ProfileState {
  final AsyncValue<UserProfile?> profile;
  final bool isSaving;
  final String? errorMessage;

  const ProfileState({
    this.profile = const AsyncValue.data(null),
    this.isSaving = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    AsyncValue<UserProfile?>? profile,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final CreateProfileUseCase createProfileUseCase;

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.createProfileUseCase,
  }) : super(const ProfileState());

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(
      profile: const AsyncValue.loading(),
      errorMessage: null,
    );

    final result = await getProfileUseCase(userId);
    result.fold(
      (failure) {
        state = state.copyWith(
          profile: AsyncValue.error(failure.message, StackTrace.current),
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(profile: AsyncValue.data(profile));
      },
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    final result = await updateProfileUseCase(profile);
    result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          profile: AsyncValue.data(profile),
          isSaving: false,
        );
      },
    );
  }

  Future<void> createProfile(UserProfile profile) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    final result = await createProfileUseCase(profile);
    result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          profile: AsyncValue.data(profile),
          isSaving: false,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
