import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/history_viewmodel.dart';

final historyViewModelProvider =
    StateNotifierProvider<HistoryViewModel, HistoryState>((ref) {
  // TODO: Inject dependencies when ready
  return HistoryViewModel();
});
