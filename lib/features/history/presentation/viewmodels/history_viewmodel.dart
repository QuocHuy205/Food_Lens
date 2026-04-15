import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/scan_history.dart';

@immutable
class HistoryState {
  final AsyncValue<List<ScanHistory>> history;
  final String? errorMessage;

  const HistoryState({
    this.history = const AsyncValue.data([]),
    this.errorMessage,
  });

  HistoryState copyWith({
    AsyncValue<List<ScanHistory>>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

class HistoryViewModel extends StateNotifier<HistoryState> {
  HistoryViewModel() : super(const HistoryState());

  Future<void> loadHistory(String userId) async {
    state = state.copyWith(history: const AsyncValue.loading());
    // TODO: Fetch from repository
  }

  Future<void> deleteItem(String scanId) async {
    // TODO: Delete from repository
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
