import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scan/presentation/providers/scan_provider.dart';
import '../viewmodels/stats_viewmodel.dart';

final statsViewModelProvider =
    StateNotifierProvider<StatsViewModel, StatsState>((ref) {
  final scanRepository = ref.watch(scanRepositoryProvider);
  return StatsViewModel(scanRepository);
});
