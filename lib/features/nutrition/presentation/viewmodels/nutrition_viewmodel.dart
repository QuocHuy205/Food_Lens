import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/daily_log.dart';

@immutable
class NutritionState {
  final AsyncValue<DailyLog?> dailyLog;
  final AsyncValue<List<DailyLog>> weeklySummary;
  final String? errorMessage;

  const NutritionState({
    this.dailyLog = const AsyncValue.data(null),
    this.weeklySummary = const AsyncValue.data([]),
    this.errorMessage,
  });

  NutritionState copyWith({
    AsyncValue<DailyLog?>? dailyLog,
    AsyncValue<List<DailyLog>>? weeklySummary,
    String? errorMessage,
  }) {
    return NutritionState(
      dailyLog: dailyLog ?? this.dailyLog,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      errorMessage: errorMessage,
    );
  }
}

class NutritionViewModel extends StateNotifier<NutritionState> {
  NutritionViewModel() : super(const NutritionState());

  Future<void> loadDailyLog(String userId, DateTime date) async {
    state = state.copyWith(dailyLog: const AsyncValue.loading());
    // TODO: Call GetDailyLogUseCase
  }

  Future<void> updateDailyLog(DailyLog log) async {
    // TODO: Call UpdateDailyLogUseCase
  }

  Future<void> loadWeeklySummary(String userId) async {
    state = state.copyWith(weeklySummary: const AsyncValue.loading());
    // TODO: Call GetWeeklySummaryUseCase
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
