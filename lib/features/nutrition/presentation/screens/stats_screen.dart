import 'package:flutter/material.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/animated_widgets.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';

// STATS SCREEN - With animations
// Refactored: Page enter + staggered content + animated period selector

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pageEnterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State
  String selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
    });
  }

  void _setupAnimations() {
    _pageEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageEnterController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                FadeInWidget(
                  delay: const Duration(milliseconds: 100),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        MapEntry('7d', l10n.last7Days),
                        MapEntry('30d', l10n.last30Days),
                        MapEntry('90d', l10n.last90Days),
                        MapEntry('1y', l10n.last1Year),
                      ].asMap().entries.map((entry) {
                        final period = entry.value.key;
                        final label = entry.value.value;
                        final index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _AnimatedPeriodChip(
                            label: label,
                            isSelected: selectedPeriod == period,
                            onTap: () =>
                                setState(() => selectedPeriod = period),
                            delay: Duration(milliseconds: 150 + (index * 50)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Summary Cards
                FadeInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSummaryCards(),
                ),
                const SizedBox(height: 24),
                // Calories Trend
                FadeInWidget(
                  delay: const Duration(milliseconds: 300),
                  child: _buildTrendChart(),
                ),
                const SizedBox(height: 24),
                // Macro Breakdown
                FadeInWidget(
                  delay: const Duration(milliseconds: 400),
                  child: _buildMacroBreakdown(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.statsTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final textSecondary = onSurface.withValues(alpha: 0.72);
    final borderColor = onSurface.withValues(alpha: 0.16);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.averageDaily,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '2,180 ${l10n.kcal}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withValues(alpha: 0.08),
                  Colors.green.withValues(alpha: 0.03),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.goalRemaining,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '+520 ${l10n.kcal}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = onSurface.withValues(alpha: 0.16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.calorieTrend,
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBarChart(
                    l10n.mon,
                    2200,
                    0.85,
                  ),
                  _buildBarChart(
                    l10n.tue,
                    2000,
                    0.78,
                  ),
                  _buildBarChart(
                    l10n.wed,
                    2350,
                    0.90,
                  ),
                  _buildBarChart(
                    l10n.thu,
                    2150,
                    0.82,
                  ),
                  _buildBarChart(
                    l10n.fri,
                    2400,
                    0.92,
                  ),
                  _buildBarChart(
                    l10n.sat,
                    1900,
                    0.73,
                  ),
                  _buildBarChart(
                    l10n.sun,
                    2100,
                    0.81,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.goalCaloriesPerDay('2,700'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String label, int kcal, double progress) {
    final textSecondary =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);

    return Column(
      children: [
        Container(
          width: 28,
          height: 120 * progress,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBreakdown() {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = onSurface.withValues(alpha: 0.16);
    final textSecondary = onSurface.withValues(alpha: 0.72);

    const proteinGrams = 145;
    const carbsGrams = 298;
    const fatGrams = 66;
    const proteinPct = 35;
    const carbsPct = 45;
    const fatPct = 20;
    const totalGrams = proteinGrams + carbsGrams + fatGrams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.macroBreakdownAverage,
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pie_chart,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$totalGrams g',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Text(
                    selectedPeriod == '7d' ? l10n.last7Days : l10n.averageDaily,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMacroRatioBar(
                proteinPercent: proteinPct,
                carbsPercent: carbsPct,
                fatPercent: fatPct,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMacroMetricCard(
                      name: l10n.protein,
                      grams: '${proteinGrams}g',
                      percent: '$proteinPct%',
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMacroMetricCard(
                      name: l10n.carbs,
                      grams: '${carbsGrams}g',
                      percent: '$carbsPct%',
                      color: const Color(0xFFFB8C00),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMacroMetricCard(
                      name: l10n.fat,
                      grams: '${fatGrams}g',
                      percent: '$fatPct%',
                      color: const Color(0xFFE53935),
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

  Widget _buildMacroRatioBar({
    required int proteinPercent,
    required int carbsPercent,
    required int fatPercent,
  }) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Row(
          children: [
            Expanded(
              flex: proteinPercent,
              child: Container(color: const Color(0xFF1E88E5)),
            ),
            Expanded(
              flex: carbsPercent,
              child: Container(color: const Color(0xFFFB8C00)),
            ),
            Expanded(
              flex: fatPercent,
              child: Container(color: const Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroMetricCard({
    required String name,
    required String grams,
    required String percent,
    required Color color,
  }) {
    final textSecondary =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            grams,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            percent,
            style: TextStyle(
              color: textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 3,
      surfaceColor: Theme.of(context).colorScheme.surface,
      borderColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16),
      unselectedItemColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );
  }
}

// Helper widgets
// HELPER WIDGETS
// Helper widgets

/// Animated period chip with scale feedback
class _AnimatedPeriodChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration delay;

  const _AnimatedPeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_AnimatedPeriodChip> createState() => _AnimatedPeriodChipState();
}

class _AnimatedPeriodChipState extends State<_AnimatedPeriodChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary : surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : borderColor,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
