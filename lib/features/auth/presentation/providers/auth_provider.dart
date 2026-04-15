import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../viewmodels/auth_viewmodel.dart';

// TODO: Wire dependencies using Riverpod
// final authRepositoryProvider = Provider((ref) {
//   return AuthRepositoryImpl(
//     firebaseAuth: FirebaseAuth.instance,
//     firebaseFirestore: FirebaseFirestore.instance,
//   );
// });

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  // TODO: Inject dependencies when ready
  return AuthViewModel();
});
