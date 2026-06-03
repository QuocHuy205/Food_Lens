import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../scan/data/datasources/firestore_datasource.dart';
import '../../../scan/presentation/providers/scan_provider.dart';
import '../viewmodels/stats_viewmodel.dart';

final statsViewModelProvider =
    StateNotifierProvider<StatsViewModel, StatsState>((ref) {
  final scanRepository = ref.watch(scanRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  final firestoreDatasource = ref.watch(firestoreDatasourceProvider);
  return StatsViewModel(
    scanRepository,
    profileRepository,
    firestoreDatasource,
  );
});
