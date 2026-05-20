import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
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
        ref.read(statsViewModelProvider.notifier).loadStats(userId, '7d');
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
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.16),
                        width: 1,
                      ),
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
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
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
      borderColor: Theme.of(context).colorScheme.outlineVariant,
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
