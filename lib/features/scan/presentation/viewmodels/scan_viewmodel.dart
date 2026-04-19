import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_history.dart';

@immutable
class ScanState {
  final AsyncValue<ScanResult?> result;
  final AsyncValue<List<ScanHistory>> history;
  final String? errorMessage;

  const ScanState({
    this.result = const AsyncValue.data(null),
    this.history = const AsyncValue.data([]),
    this.errorMessage,
  });

  ScanState copyWith({
    AsyncValue<ScanResult?>? result,
    AsyncValue<List<ScanHistory>>? history,
    String? errorMessage,
  }) {
    return ScanState(
      result: result ?? this.result,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

class ScanViewModel extends StateNotifier<ScanState> {
  ScanViewModel() : super(const ScanState());

  Future<void> analyzeImage(String imageUrl) async {
    state = state.copyWith(result: const AsyncValue.loading());
    // TODO: Call AnalyzeFoodUseCase
  }

  Future<void> saveScanHistory(ScanHistory history) async {
    // TODO: Call SaveScanHistoryUseCase
  }

  Future<void> loadScanHistory(String userId) async {
    state = state.copyWith(history: const AsyncValue.loading());
    // TODO: Fetch from repository
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
