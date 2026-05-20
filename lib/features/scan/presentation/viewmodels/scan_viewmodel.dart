import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/scan_history.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/analyze_food_usecase.dart';
import '../../domain/usecases/save_scan_history_usecase.dart';

const Object _scanStateUnset = Object();

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
    Object? errorMessage = _scanStateUnset,
  }) {
    return ScanState(
      result: result ?? this.result,
      history: history ?? this.history,
      errorMessage: identical(errorMessage, _scanStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class ScanViewModel extends StateNotifier<ScanState> {
  final AnalyzeFoodUseCase _analyzeFoodUseCase;
  final SaveScanHistoryUseCase _saveScanHistoryUseCase;
  final ScanRepository _scanRepository;

  ScanViewModel({
    required AnalyzeFoodUseCase analyzeFoodUseCase,
    required SaveScanHistoryUseCase saveScanHistoryUseCase,
    required ScanRepository scanRepository,
  })  : _analyzeFoodUseCase = analyzeFoodUseCase,
        _saveScanHistoryUseCase = saveScanHistoryUseCase,
        _scanRepository = scanRepository,
        super(const ScanState());

  Future<void> analyzeImage(File imageFile) async {
    state = state.copyWith(result: const AsyncValue.loading());
    final result = await _analyzeFoodUseCase(imageFile);

    result.match(
      (failure) {
        state = state.copyWith(
          result: AsyncValue.error(failure.message, StackTrace.current),
          errorMessage: failure.message,
        );
      },
      (scanResult) {
        state = state.copyWith(
          result: AsyncValue.data(scanResult),
          errorMessage: null,
        );
      },
    );
  }

  Future<void> saveScanHistory(ScanHistory history) async {
    final result = await _saveScanHistoryUseCase(history);

    result.match(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(errorMessage: null);
      },
    );
  }

  Future<void> loadScanHistory(String userId) async {
    state = state.copyWith(history: const AsyncValue.loading());

    final result = await _scanRepository.getScanHistory(userId);
    result.match(
      (failure) {
        state = state.copyWith(
          history: AsyncValue.error(failure.message, StackTrace.current),
          errorMessage: failure.message,
        );
      },
      (histories) {
        state = state.copyWith(
          history: AsyncValue.data(histories),
          errorMessage: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
