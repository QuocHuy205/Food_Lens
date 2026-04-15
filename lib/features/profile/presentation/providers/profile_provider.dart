import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/profile_viewmodel.dart';

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  // TODO: Inject dependencies when ready
  return ProfileViewModel();
});
