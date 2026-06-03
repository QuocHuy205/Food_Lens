import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../scan/data/datasources/firestore_datasource.dart';
import '../../../scan/domain/entities/scan_history.dart';
import '../../../scan/domain/repositories/scan_repository.dart';

@immutable
class StatsRecommendation {
  final String id;
  final String localeCode;
  final String title;
  final String summary;
  final String focus;
  final List<String> suggestedFoods;
  final List<String> actionTips;
  final int targetCalories;
  final int consumedCalories;
  final int remainingCalories;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final String period;
  final DateTime generatedAt;

  const StatsRecommendation({
    required this.id,
    required this.localeCode,
    required this.title,
    required this.summary,
    required this.focus,
    required this.suggestedFoods,
    required this.actionTips,
    required this.targetCalories,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    required this.period,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson({required String userId}) {
    return {
      'id': id,
      'userId': userId,
      'localeCode': localeCode,
      'title': title,
      'summary': summary,
      'focus': focus,
      'suggestedFoods': suggestedFoods,
      'actionTips': actionTips,
      'targetCalories': targetCalories,
      'consumedCalories': consumedCalories,
      'remainingCalories': remainingCalories,
      'proteinPercent': proteinPercent,
      'carbsPercent': carbsPercent,
      'fatPercent': fatPercent,
      'period': period,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

@immutable
class StatsState {
  final AsyncValue<List<ScanHistory>> historyData;
  final AsyncValue<StatsRecommendation?> recommendationData;
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
    this.recommendationData = const AsyncValue.data(null),
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
    AsyncValue<StatsRecommendation?>? recommendationData,
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
      recommendationData: recommendationData ?? this.recommendationData,
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
  final ScanRepository _scanRepository;
  final ProfileRepository _profileRepository;
  final FirestoreDatasource _firestoreDatasource;
  String? _userId;
  String _localeCode = 'vi';

  StatsViewModel(
    this._scanRepository,
    this._profileRepository,
    this._firestoreDatasource,
  ) : super(const StatsState());

  Future<void> loadStats(
    String userId,
    String period, [
    String? languageCode,
  ]) async {
    _userId = userId;
    _localeCode = languageCode ?? _localeCode;
    state = state.copyWith(
      historyData: const AsyncValue.loading(),
      recommendationData: const AsyncValue.loading(),
      period: period,
      errorMessage: null,
    );

    final profileResult = await _profileRepository.getProfile(userId);
    final profile = profileResult.fold<UserProfile?>(
      (_) => null,
      (value) => value,
    );

    final result = await _scanRepository.getScanHistory(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          historyData: AsyncValue.error(
            'Lỗi tải dữ liệu: ${failure.message}',
            StackTrace.current,
          ),
          errorMessage: 'Lỗi tải dữ liệu: ${failure.message}',
          recommendationData: const AsyncValue.data(null),
        );
      },
      (items) {
        final filtered = _filterByPeriod(items, period);
        final metrics = _calculateMetrics(filtered);
        final recommendation = _buildRecommendation(
          items: filtered,
          profile: profile,
          period: period,
          metrics: metrics,
          localeCode: _localeCode,
        );

        state = state.copyWith(
          historyData: AsyncValue.data(filtered),
          recommendationData: AsyncValue.data(recommendation),
          totalCalories: metrics.totalCalories,
          dailyAverageCalories: metrics.dailyAverageCalories,
          totalProtein: metrics.totalProtein,
          totalCarbs: metrics.totalCarbs,
          totalFat: metrics.totalFat,
          totalFiber: metrics.totalFiber,
        );

        _persistRecommendation(userId, recommendation);
      },
    );
  }

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

  _StatsMetrics _calculateMetrics(List<ScanHistory> items) {
    if (items.isEmpty) {
      return const _StatsMetrics(
        totalCalories: 0.0,
        dailyAverageCalories: 0.0,
        totalProtein: 0.0,
        totalCarbs: 0.0,
        totalFat: 0.0,
        totalFiber: 0.0,
      );
    }

    final totalCalories = items.fold(0.0, (sum, item) => sum + item.calories);

    final uniqueDates = <String>{};
    for (final item in items) {
      final dateStr =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
      uniqueDates.add(dateStr);
    }

    final daysCount = uniqueDates.isEmpty ? 1 : uniqueDates.length;
    final dailyAverage = totalCalories / daysCount;

    final totalProtein = totalCalories * 0.25 / 4;
    final totalCarbs = totalCalories * 0.50 / 4;
    final totalFat = totalCalories * 0.25 / 9;
    final totalFiber = items.length * 2.5;

    return _StatsMetrics(
      totalCalories: totalCalories,
      dailyAverageCalories: dailyAverage,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
    );
  }

  StatsRecommendation _buildRecommendation({
    required List<ScanHistory> items,
    required UserProfile? profile,
    required String period,
    required _StatsMetrics metrics,
    required String localeCode,
  }) {
    final targetCalories = profile?.dailyCalorieTarget?.round() ?? 0;
    final consumedCalories = metrics.totalCalories.round();
    final remainingCalories = targetCalories > 0
        ? (targetCalories - consumedCalories).clamp(0, 1 << 31)
        : 0;

    final macroCalories = metrics.totalProtein * 4 +
        metrics.totalCarbs * 4 +
        metrics.totalFat * 9;
    final proteinPercent =
        macroCalories > 0 ? (metrics.totalProtein * 4 / macroCalories) : 0.0;
    final carbsPercent =
        macroCalories > 0 ? (metrics.totalCarbs * 4 / macroCalories) : 0.0;
    final fatPercent =
        macroCalories > 0 ? (metrics.totalFat * 9 / macroCalories) : 0.0;

    final recentFoods = _collectRecentFoods(items);
    final mealContext = _mealContext(localeCode, DateTime.now());
    final title = _buildRecommendationTitle(
      localeCode: localeCode,
      targetCalories: targetCalories,
      remainingCalories: remainingCalories,
      mealContext: mealContext,
    );
    final summary = _buildRecommendationSummary(
      localeCode: localeCode,
      targetCalories: targetCalories,
      remainingCalories: remainingCalories,
      proteinPercent: proteinPercent,
      carbsPercent: carbsPercent,
      fatPercent: fatPercent,
      recentFoods: recentFoods,
      mealContext: mealContext,
    );
    final focus = _buildRecommendationFocus(
      localeCode: localeCode,
      remainingCalories: remainingCalories,
      proteinPercent: proteinPercent,
      carbsPercent: carbsPercent,
      fatPercent: fatPercent,
      mealContext: mealContext,
    );

    return StatsRecommendation(
      id: _dateKey(DateTime.now()),
      localeCode: localeCode,
      title: title,
      summary: summary,
      focus: focus,
      suggestedFoods: _buildSuggestedFoods(
        localeCode: localeCode,
        items: items,
        remainingCalories: remainingCalories,
        proteinPercent: proteinPercent,
        carbsPercent: carbsPercent,
        fatPercent: fatPercent,
        mealContext: mealContext,
      ),
      actionTips: _buildActionTips(
        localeCode: localeCode,
        items: items,
        remainingCalories: remainingCalories,
        proteinPercent: proteinPercent,
        carbsPercent: carbsPercent,
        fatPercent: fatPercent,
        mealContext: mealContext,
      ),
      targetCalories: targetCalories,
      consumedCalories: consumedCalories,
      remainingCalories: remainingCalories,
      proteinPercent: proteinPercent,
      carbsPercent: carbsPercent,
      fatPercent: fatPercent,
      period: period,
      generatedAt: DateTime.now(),
    );
  }

  String _buildRecommendationTitle({
    required String localeCode,
    required int targetCalories,
    required int remainingCalories,
    required String mealContext,
  }) {
    if (targetCalories <= 0) {
      return _localized(localeCode,
          vi: 'Chưa đủ dữ liệu để gợi ý',
          en: 'Not enough data to generate a plan');
    }

    if (remainingCalories > 500) {
      return _localized(localeCode,
          vi: 'Bạn còn dư năng lượng cho bữa chính',
          en: 'You still have room for a full meal');
    }

    if (remainingCalories > 0) {
      return _localized(localeCode,
          vi: 'Nên chọn bữa nhẹ cân bằng hơn',
          en: 'A lighter balanced meal fits best');
    }

    return _localized(localeCode,
        vi: 'Hôm nay đã chạm ngưỡng mục tiêu',
        en: 'You have already hit today\'s target');
  }

  String _buildRecommendationSummary({
    required String localeCode,
    required int targetCalories,
    required int remainingCalories,
    required double proteinPercent,
    required double carbsPercent,
    required double fatPercent,
    required List<String> recentFoods,
    required String mealContext,
  }) {
    if (targetCalories <= 0) {
      return _localized(
        localeCode,
        vi: 'Hãy hoàn thiện hồ sơ TDEE để hệ thống gợi ý chính xác hơn.',
        en: 'Complete your TDEE profile so the recommendations can become more accurate.',
      );
    }

    final recentHint = recentFoods.isNotEmpty
        ? _localized(
            localeCode,
            vi: ' Món gần nhất bạn quét: ${recentFoods.first}.',
            en: ' Your latest scan: ${recentFoods.first}.',
          )
        : '';

    if (remainingCalories > 0) {
      return _localized(
            localeCode,
            vi: 'Trong $mealContext, bạn còn khoảng $remainingCalories kcal để chạm mốc $targetCalories kcal. Tỷ lệ hiện tại: đạm ${(proteinPercent * 100).toStringAsFixed(0)}%, tinh bột ${(carbsPercent * 100).toStringAsFixed(0)}%, chất béo ${(fatPercent * 100).toStringAsFixed(0)}%.',
            en: 'For $mealContext, you still have about $remainingCalories kcal to reach your $targetCalories kcal target. Current split: protein ${(proteinPercent * 100).toStringAsFixed(0)}%, carbs ${(carbsPercent * 100).toStringAsFixed(0)}%, fat ${(fatPercent * 100).toStringAsFixed(0)}%.',
          ) +
          recentHint;
    }

    return _localized(
      localeCode,
      vi: 'Bạn đã vượt mục tiêu khoảng ${remainingCalories.abs()} kcal. Hãy ưu tiên món ít dầu, nhiều rau và đạm nạc.',
      en: 'You are about ${remainingCalories.abs()} kcal over target. Prioritize lower-oil meals with vegetables and lean protein.',
    );
  }

  String _buildRecommendationFocus({
    required String localeCode,
    required int remainingCalories,
    required double proteinPercent,
    required double carbsPercent,
    required double fatPercent,
    required String mealContext,
  }) {
    if (remainingCalories <= 0) {
      return _localized(localeCode, vi: 'Giảm calo', en: 'Trim calories');
    }

    if (proteinPercent < 0.22) {
      return _localized(localeCode, vi: 'Tăng đạm', en: 'Boost protein');
    }

    if (carbsPercent > 0.55) {
      return _localized(localeCode, vi: 'Giảm tinh bột', en: 'Cut carbs');
    }

    if (fatPercent > 0.32) {
      return _localized(localeCode, vi: 'Giảm dầu mỡ', en: 'Go lighter on fat');
    }

    return _localized(localeCode, vi: 'Cân bằng tốt', en: 'Well balanced');
  }

  List<String> _buildSuggestedFoods({
    required String localeCode,
    required List<ScanHistory> items,
    required int remainingCalories,
    required double proteinPercent,
    required double carbsPercent,
    required double fatPercent,
    required String mealContext,
  }) {
    final suggestions = <String>[];
    final recentFoods = _collectRecentFoods(items);
    final isVi = localeCode == 'vi';

    if (remainingCalories <= 0) {
      suggestions.addAll([
        _localized(localeCode,
            vi: 'Canh rau + đậu hũ non', en: 'Vegetable soup + soft tofu'),
        _localized(localeCode, vi: 'Salad ức gà', en: 'Chicken breast salad'),
        _localized(localeCode,
            vi: 'Sữa chua không đường', en: 'Unsweetened yogurt'),
      ]);
    } else if (proteinPercent < 0.22) {
      suggestions.addAll([
        _localized(localeCode,
            vi: 'Ức gà nướng + rau luộc',
            en: 'Grilled chicken breast + vegetables'),
        _localized(localeCode,
            vi: '2 quả trứng luộc + cà chua', en: '2 boiled eggs + tomatoes'),
        _localized(localeCode,
            vi: 'Cá hấp + bông cải', en: 'Steamed fish + broccoli'),
      ]);
    } else if (carbsPercent > 0.55) {
      suggestions.addAll([
        _localized(localeCode,
            vi: 'Salad rau xanh + cá ngừ', en: 'Green salad + tuna'),
        _localized(localeCode,
            vi: 'Khoai lang luộc', en: 'Boiled sweet potato'),
        _localized(localeCode, vi: 'Yến mạch + sữa chua', en: 'Oats + yogurt'),
      ]);
    } else if (fatPercent > 0.32) {
      suggestions.addAll([
        _localized(localeCode,
            vi: 'Cơm gạo lứt + ức gà', en: 'Brown rice + chicken breast'),
        _localized(localeCode, vi: 'Canh chua cá', en: 'Sour fish soup'),
        _localized(localeCode,
            vi: 'Đậu hũ non + rau củ hấp',
            en: 'Soft tofu + steamed vegetables'),
      ]);
    } else if (remainingCalories > 650) {
      suggestions.addAll([
        _localized(localeCode,
            vi: 'Cơm gạo lứt + thịt nạc', en: 'Brown rice + lean meat'),
        _localized(localeCode,
            vi: 'Bún gạo lứt gà xé', en: 'Shredded chicken rice noodles'),
        _localized(localeCode,
            vi: 'Cá hấp + rau luộc', en: 'Steamed fish + boiled vegetables'),
      ]);
    } else {
      suggestions.addAll([
        _localized(localeCode,
            vi: 'Sữa chua Hy Lạp + hạt', en: 'Greek yogurt + nuts'),
        _localized(localeCode,
            vi: 'Trứng luộc + salad', en: 'Boiled eggs + salad'),
        _localized(localeCode,
            vi: 'Khoai lang + ức gà', en: 'Sweet potato + chicken breast'),
      ]);
    }

    if (recentFoods.isNotEmpty) {
      suggestions.add(
        isVi
            ? 'Hạn chế lặp lại ${recentFoods.first} ở bữa kế tiếp'
            : 'Avoid repeating ${recentFoods.first} in the next meal',
      );
    }

    return _uniqueTake(suggestions, 3);
  }

  List<String> _buildActionTips({
    required String localeCode,
    required List<ScanHistory> items,
    required int remainingCalories,
    required double proteinPercent,
    required double carbsPercent,
    required double fatPercent,
    required String mealContext,
  }) {
    final tips = <String>[];
    final recentFoods = _collectRecentFoods(items);

    if (remainingCalories <= 0) {
      tips.add(_localized(localeCode,
          vi: 'Giữ bữa sau nhẹ và nhiều rau',
          en: 'Keep the next meal lighter and vegetable-rich'));
      tips.add(_localized(localeCode,
          vi: 'Hạn chế đồ chiên và nước ngọt',
          en: 'Reduce fried foods and sugary drinks'));
    } else {
      tips.add(_localized(localeCode,
          vi: 'Chọn 1 món chính + 1 món rau để no lâu hơn',
          en: 'Pair one main dish with one vegetable side for better satiety'));
    }

    if (proteinPercent < 0.22) {
      tips.add(_localized(localeCode,
          vi: 'Bổ sung thêm đạm nạc trong bữa kế tiếp',
          en: 'Add lean protein in your next meal'));
    }

    if (carbsPercent > 0.55) {
      tips.add(_localized(localeCode,
          vi: 'Giảm bớt cơm/bún/mì trong phần ăn tiếp theo',
          en: 'Scale back rice/noodles in the next serving'));
    }

    if (fatPercent > 0.32) {
      tips.add(_localized(localeCode,
          vi: 'Ưu tiên món hấp, luộc, áp chảo ít dầu',
          en: 'Prefer steamed, boiled, or lightly pan-seared dishes'));
    }

    if (recentFoods.length >= 2) {
      tips.add(_localized(localeCode,
          vi: 'Đa dạng món hơn để tránh lặp khẩu vị',
          en: 'Rotate dishes more often to avoid repetitive eating'));
    }

    if (tips.length < 2) {
      tips.add(_localized(localeCode,
          vi: 'Uống đủ nước và chia bữa hợp lý',
          en: 'Stay hydrated and spread meals more evenly'));
    }

    return _uniqueTake(tips, 3);
  }

  Future<void> _persistRecommendation(
    String userId,
    StatsRecommendation recommendation,
  ) async {
    try {
      await _firestoreDatasource.saveRecommendationSnapshot(
        userId,
        recommendation.toJson(userId: userId),
      );
    } catch (_) {
      // Best-effort sync only.
    }
  }

  String _dateKey(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day';
  }

  List<String> _collectRecentFoods(List<ScanHistory> items) {
    return items.reversed
        .map((item) => item.foodName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .take(3)
        .toList();
  }

  List<String> _uniqueTake(List<String> items, int count) {
    final unique = <String>[];
    for (final item in items) {
      if (unique.contains(item)) {
        continue;
      }
      unique.add(item);
      if (unique.length == count) {
        break;
      }
    }
    return unique;
  }

  String _mealContext(String localeCode, DateTime now) {
    final hour = now.hour;
    if (hour < 10) {
      return _localized(localeCode, vi: 'bữa sáng', en: 'breakfast');
    }
    if (hour < 14) {
      return _localized(localeCode, vi: 'bữa trưa', en: 'lunch');
    }
    if (hour < 18) {
      return _localized(localeCode, vi: 'bữa xế', en: 'afternoon snack');
    }
    return _localized(localeCode, vi: 'bữa tối', en: 'dinner');
  }

  String _localized(
    String localeCode, {
    required String vi,
    required String en,
  }) {
    return localeCode == 'vi' ? vi : en;
  }

  Future<void> changePeriod(String period) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    await loadStats(userId, period, _localeCode);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

@immutable
class _StatsMetrics {
  final double totalCalories;
  final double dailyAverageCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;

  const _StatsMetrics({
    required this.totalCalories,
    required this.dailyAverageCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
  });
}
