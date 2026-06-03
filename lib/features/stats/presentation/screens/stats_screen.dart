import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/theme/locale_provider.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';
import '../providers/stats_provider.dart';
import '../viewmodels/stats_viewmodel.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageEnterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        ref.read(statsViewModelProvider.notifier).loadStats(
            userId, '7d', Localizations.localeOf(context).languageCode);
      }
    });
  }

  void _setupAnimations() {
    _pageEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _pageEnterController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageEnterController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageEnterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsState = ref.watch(statsViewModelProvider);
    ref.listen<Locale?>(localeProvider, (previous, next) {
      if (previous?.languageCode == next?.languageCode) {
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        ref
            .read(statsViewModelProvider.notifier)
            .loadStats(userId, statsState.period, next?.languageCode);
      }
    });

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                _buildPeriodSelector(context, l10n, ref, statsState),
                const SizedBox(height: 24),

                // Summary Cards
                _buildSummaryCards(context, l10n, statsState),
                const SizedBox(height: 24),

                // Recommendation Panel
                _buildRecommendationPanel(context, statsState),
                const SizedBox(height: 24),

                // Macro Breakdown
                _buildMacroBreakdown(context, l10n, statsState),
                const SizedBox(height: 24),

                // Statistics
                _buildDetailedStats(context, l10n, statsState),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      title: Text(l10n.statsTitle),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    StatsState statsState,
  ) {
    final periods = [
      {'key': '7d', 'label': l10n.last7Days},
      {'key': '30d', 'label': l10n.last30Days},
      {'key': '90d', 'label': l10n.last90Days},
      {'key': '1y', 'label': l10n.last1Year},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(context, vi: 'Thời gian', en: 'Period'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: periods.map((period) {
              final isSelected = statsState.period == period['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(statsViewModelProvider.notifier)
                        .changePeriod(period['key']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      period['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AppLocalizations l10n,
    StatsState statsState,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.totalCalories,
            '${statsState.totalCalories.toStringAsFixed(0)} kcal',
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.dailyCalories,
            '${statsState.dailyAverageCalories.toStringAsFixed(0)} kcal',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPanel(
    BuildContext context,
    StatsState statsState,
  ) {
    final recommendation = statsState.recommendationData.valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const [Color(0xFF0F2F1A), Color(0xFF1F5E33)]
        : const [Color(0xFF1B5E20), Color(0xFF43A047)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(context,
              vi: 'Đề xuất dinh dưỡng', en: 'Nutrition Plan'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: recommendation == null
              ? _buildRecommendationLoading(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                recommendation.summary,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            recommendation.focus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recommendation.suggestedFoods
                          .map(
                            (food) => _buildRecommendationChip(
                              food,
                              Colors.white.withValues(alpha: 0.16),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recommendation.actionTips
                          .map(
                            (tip) => _buildRecommendationChip(
                              tip,
                              Colors.white.withValues(alpha: 0.10),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniMetric(
                            _localizedText(context,
                                vi: 'Mục tiêu', en: 'Target'),
                            '${recommendation.targetCalories} kcal',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniMetric(
                            _localizedText(context,
                                vi: 'Còn lại', en: 'Remaining'),
                            '${recommendation.remainingCalories} kcal',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendationLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(context,
              vi: 'Đang tính đề xuất...', en: 'Calculating plan...'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _localizedText(
            context,
            vi: 'Hệ thống đang tổng hợp từ TDEE và lịch sử scan.',
            en: 'The system is combining TDEE with your scan history.',
          ),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationChip(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown(
    BuildContext context,
    AppLocalizations l10n,
    StatsState statsState,
  ) {
    final totalMacro =
        statsState.totalProtein + statsState.totalCarbs + statsState.totalFat;
    final proteinPercent = totalMacro > 0
        ? (statsState.totalProtein / totalMacro * 100).toStringAsFixed(0)
        : '0';
    final carbsPercent = totalMacro > 0
        ? (statsState.totalCarbs / totalMacro * 100).toStringAsFixed(0)
        : '0';
    final fatPercent = totalMacro > 0
        ? (statsState.totalFat / totalMacro * 100).toStringAsFixed(0)
        : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(context, vi: 'Phân bố Macro', en: 'Macro Breakdown'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildMacroRow(
                l10n.protein,
                '${statsState.totalProtein.toStringAsFixed(0)}g',
                '$proteinPercent%',
                Colors.blue,
                totalMacro > 0 ? statsState.totalProtein / totalMacro : 0,
              ),
              const SizedBox(height: 14),
              _buildMacroRow(
                l10n.carbs,
                '${statsState.totalCarbs.toStringAsFixed(0)}g',
                '$carbsPercent%',
                Colors.orange,
                totalMacro > 0 ? statsState.totalCarbs / totalMacro : 0,
              ),
              const SizedBox(height: 14),
              _buildMacroRow(
                l10n.fat,
                '${statsState.totalFat.toStringAsFixed(0)}g',
                '$fatPercent%',
                Colors.red,
                totalMacro > 0 ? statsState.totalFat / totalMacro : 0,
              ),
              const SizedBox(height: 14),
              _buildMacroRow(
                l10n.fiber,
                '${statsState.totalFiber.toStringAsFixed(1)}g',
                '100%',
                Colors.green,
                1.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(
    String label,
    String value,
    String percent,
    Color color,
    double ratio,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  percent,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: color.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(
    BuildContext context,
    AppLocalizations l10n,
    StatsState statsState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedText(context, vi: 'Chi tiết', en: 'Details'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildStatRow(
                _localizedText(context, vi: 'Tổng lần ăn', en: 'Meals'),
                statsState.historyData.valueOrNull?.length.toString() ?? '0',
              ),
              const Divider(height: 16),
              _buildStatRow(
                l10n.totalCalories,
                '${statsState.totalCalories.toStringAsFixed(0)} kcal',
              ),
              const Divider(height: 16),
              _buildStatRow(
                l10n.dailyCalories,
                '${statsState.dailyAverageCalories.toStringAsFixed(0)} kcal',
              ),
              const Divider(height: 16),
              _buildStatRow(
                l10n.protein,
                '${statsState.totalProtein.toStringAsFixed(1)}g',
              ),
              const Divider(height: 16),
              _buildStatRow(
                l10n.carbs,
                '${statsState.totalCarbs.toStringAsFixed(1)}g',
              ),
              const Divider(height: 16),
              _buildStatRow(
                l10n.fat,
                '${statsState.totalFat.toStringAsFixed(1)}g',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 3,
      surfaceColor: Theme.of(context).colorScheme.surface,
      unselectedItemColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
  }
}

String _localizedText(
  BuildContext context, {
  required String vi,
  required String en,
}) {
  return Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
}
