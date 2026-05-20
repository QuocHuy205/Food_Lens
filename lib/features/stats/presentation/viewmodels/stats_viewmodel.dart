import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scan/domain/entities/scan_history.dart';
import '../../../scan/domain/repositories/scan_repository.dart';

@immutable
class StatsState {
  final AsyncValue<List<ScanHistory>> historyData;
  final String period; // '7d', '30d', '90d', '1y'
  final double totalCalories;
  final double dailyAverageCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final String? errorMessage;

  const StatsState({
    this.historyData = const AsyncValue.data([]),
    this.period = '7d',
    this.totalCalories = 0.0,
    this.dailyAverageCalories = 0.0,
    this.totalProtein = 0.0,
    this.totalCarbs = 0.0,
    this.totalFat = 0.0,
    this.totalFiber = 0.0,
    this.errorMessage,
  });

  StatsState copyWith({
    AsyncValue<List<ScanHistory>>? historyData,
    String? period,
    double? totalCalories,
    double? dailyAverageCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    String? errorMessage,
  }) {
    return StatsState(
      historyData: historyData ?? this.historyData,
      period: period ?? this.period,
      totalCalories: totalCalories ?? this.totalCalories,
      dailyAverageCalories: dailyAverageCalories ?? this.dailyAverageCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      errorMessage: errorMessage,
    );
  }
}

class StatsViewModel extends StateNotifier<StatsState> {
  final ScanRepository _repository;
  String? _userId;

  StatsViewModel(this._repository) : super(const StatsState());

  // Load stats for a period
  Future<void> loadStats(String userId, String period) async {
    _userId = userId;
    state = state.copyWith(
      historyData: const AsyncValue.loading(),
      period: period,
      errorMessage: null,
    );

    final result = await _repository.getScanHistory(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          historyData: AsyncValue.error(
            'Lỗi tải dữ liệu: ${failure.message}',
            StackTrace.current,
          ),
          errorMessage: 'Lỗi tải dữ liệu: ${failure.message}',
        );
      },
      (items) {
        // Filter by period
        final filtered = _filterByPeriod(items, period);
        state = state.copyWith(historyData: AsyncValue.data(filtered));
        _calculateStats(filtered);
      },
    );
  }

  // Filter history by period
  List<ScanHistory> _filterByPeriod(List<ScanHistory> items, String period) {
    final now = DateTime.now();
    final startDate = switch (period) {
      '7d' => now.subtract(const Duration(days: 7)),
      '30d' => now.subtract(const Duration(days: 30)),
      '90d' => now.subtract(const Duration(days: 90)),
      '1y' => now.subtract(const Duration(days: 365)),
      _ => now.subtract(const Duration(days: 7)),
    };

    return items.where((item) => item.createdAt.isAfter(startDate)).toList();
  }

  // Calculate stats
  void _calculateStats(List<ScanHistory> items) {
    if (items.isEmpty) {
      state = state.copyWith(
        totalCalories: 0.0,
        dailyAverageCalories: 0.0,
        totalProtein: 0.0,
        totalCarbs: 0.0,
        totalFat: 0.0,
        totalFiber: 0.0,
      );
      return;
    }

    // Calculate total calories
    final totalCalories = items.fold(0.0, (sum, item) => sum + item.calories);

    // Get unique dates count
    final uniqueDates = <String>{};
    for (final item in items) {
      final dateStr =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
      uniqueDates.add(dateStr);
    }

    final daysCount = uniqueDates.isEmpty ? 1 : uniqueDates.length;
    final dailyAverage = totalCalories / daysCount;

    // Calculate macros (estimated based on food composition)
    // These are rough estimates - in production, use actual nutrition DB
    final totalProtein =
        totalCalories * 0.25 / 4; // 25% of calories from protein (4 cal/g)
    final totalCarbs = totalCalories * 0.50 / 4; // 50% from carbs (4 cal/g)
    final totalFat = totalCalories * 0.25 / 9; // 25% from fat (9 cal/g)
    final totalFiber = items.length * 2.5; // Rough estimate

    state = state.copyWith(
      totalCalories: totalCalories,
      dailyAverageCalories: dailyAverage,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
    );
  }

  // Change period
  Future<void> changePeriod(String period) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    await loadStats(userId, period);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
