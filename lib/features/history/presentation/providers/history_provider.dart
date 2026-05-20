import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scan/presentation/providers/scan_provider.dart';
import '../viewmodels/history_viewmodel.dart';

final historyViewModelProvider =
    StateNotifierProvider<HistoryViewModel, HistoryState>((ref) {
  final scanRepository = ref.watch(scanRepositoryProvider);
  return HistoryViewModel(scanRepository);
});
