import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scan/domain/entities/scan_history.dart';
import '../../../scan/domain/repositories/scan_repository.dart';

@immutable
class HistoryState {
  final AsyncValue<List<ScanHistory>> history;
  final List<ScanHistory> filteredItems;
  final String currentFilter; // 'all', 'today', 'week', 'month'
  final String searchQuery;
  final String? errorMessage;

  const HistoryState({
    this.history = const AsyncValue.data([]),
    this.filteredItems = const [],
    this.currentFilter = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  HistoryState copyWith({
    AsyncValue<List<ScanHistory>>? history,
    List<ScanHistory>? filteredItems,
    String? currentFilter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HistoryState(
      history: history ?? this.history,
      filteredItems: filteredItems ?? this.filteredItems,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class HistoryViewModel extends StateNotifier<HistoryState> {
  final ScanRepository _repository;

  HistoryViewModel(this._repository) : super(const HistoryState());

  // Load history from Firestore
  Future<void> loadHistory(String userId) async {
    state = state.copyWith(
      history: const AsyncValue.loading(),
      errorMessage: null,
    );

    final result = await _repository.getScanHistory(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          history: AsyncValue.error(
            'Lỗi tải lịch sử: ${failure.message}',
            StackTrace.current,
          ),
          errorMessage: 'Lỗi tải lịch sử: ${failure.message}',
        );
      },
      (items) {
        // Sort by date descending
        final sorted = items
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = state.copyWith(
          history: AsyncValue.data(sorted),
          filteredItems: sorted,
        );
        _applyFilters();
      },
    );
  }

  // Filter by date (all/today/week/month)
  void filterByDate(String filter) {
    state = state.copyWith(currentFilter: filter);
    _applyFilters();
  }

  // Search food by name
  void searchFood(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  // Apply current filters
  void _applyFilters() {
    final historyData = state.history.valueOrNull ?? [];
    var filtered = List<ScanHistory>.from(historyData);

    // Apply date filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    if (state.currentFilter == 'today') {
      filtered = filtered.where((item) {
        final itemDate = DateTime(
            item.createdAt.year, item.createdAt.month, item.createdAt.day);
        return itemDate == today;
      }).toList();
    } else if (state.currentFilter == 'week') {
      filtered = filtered.where((item) {
        final itemDate = DateTime(
            item.createdAt.year, item.createdAt.month, item.createdAt.day);
        return itemDate.isAfter(weekAgo) || itemDate == weekAgo;
      }).toList();
    } else if (state.currentFilter == 'month') {
      filtered = filtered.where((item) {
        final itemDate = DateTime(
            item.createdAt.year, item.createdAt.month, item.createdAt.day);
        return itemDate.isAfter(monthAgo) || itemDate == monthAgo;
      }).toList();
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) => item.foodName
              .toLowerCase()
              .contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    state = state.copyWith(filteredItems: filtered);
  }

  // Delete history item
  Future<void> deleteHistoryItem(String userId, String scanId) async {
    try {
      final result = await _repository.deleteScanHistory(userId, scanId);
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Lỗi xóa: ${failure.message}',
          );
        },
        (_) {
          final currentHistory = state.history.valueOrNull ?? [];
          final updated =
              currentHistory.where((item) => item.id != scanId).toList();
          state = state.copyWith(
            history: AsyncValue.data(updated),
          );
          _applyFilters();
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi xóa: $e');
    }
  }

  // Update quantity/calories for a history item
  Future<void> updateHistoryItem(ScanHistory updatedItem) async {
    try {
      final result = await _repository.updateScanHistory(updatedItem);
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Lỗi cập nhật: ${failure.message}',
          );
        },
        (_) {
          final currentHistory = state.history.valueOrNull ?? [];
          final updated = currentHistory
              .map((item) => item.id == updatedItem.id ? updatedItem : item)
              .toList();
          state = state.copyWith(
            history: AsyncValue.data(updated),
          );
          _applyFilters();
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi cập nhật: $e');
    }
  }

  // Calculate total calories for a date
  double getDailyTotalCalories(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final items = state.history.valueOrNull ?? [];
    return items.where((item) {
      final itemDateStr =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
      return itemDateStr == dateStr;
    }).fold(0.0, (sum, item) => sum + item.calories);
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
