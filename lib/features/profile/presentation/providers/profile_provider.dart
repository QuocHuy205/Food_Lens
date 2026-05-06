import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_lens/core/services/api_service.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../viewmodels/profile_viewmodel.dart';

final profileFirebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});


final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {


  // Lấy apiServiceProvider (đảm bảo bạn đã export hoặc import đúng file chứa nó)
  final apiService = ref.watch(apiServiceProvider);
  final auth = ref.watch(profileFirebaseAuthProvider);

  return ProfileRepositoryImpl(
    apiService: apiService, // Truyền apiService thay vì firestore
    auth: auth,
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});

final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  return CreateProfileUseCase(repository: ref.watch(profileRepositoryProvider));
});

final profileViewModelProvider =
StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    createProfileUseCase: ref.watch(createProfileUseCaseProvider),
  );
});