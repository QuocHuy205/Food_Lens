import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user_profile.dart';

@immutable
class ProfileState {
  final AsyncValue<UserProfile?> profile;
  final String? errorMessage;

  const ProfileState({
    this.profile = const AsyncValue.data(null),
    this.errorMessage,
  });

  ProfileState copyWith({
    AsyncValue<UserProfile?>? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel() : super(const ProfileState());

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(profile: const AsyncValue.loading());
    // TODO: Call GetProfileUseCase
  }

  Future<void> updateProfile(UserProfile profile) async {
    // TODO: Call UpdateProfileUseCase
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
