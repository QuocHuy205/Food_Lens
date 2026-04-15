import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/scan_viewmodel.dart';

final scanViewModelProvider =
    StateNotifierProvider<ScanViewModel, ScanState>((ref) {
  // TODO: Inject dependencies when ready
  return ScanViewModel();
});
