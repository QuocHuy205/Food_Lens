import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen>
    with TickerProviderStateMixin {
  int quantity = 1;
  late AnimationController _slideController;
  late AnimationController _metricController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _metricController.forward();
    });
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _metricController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildFoodImage(),
                const SizedBox(height: 20),
                _buildFoodInfo(),
                const SizedBox(height: 20),
                _buildQuantitySelector(),
                const SizedBox(height: 20),
                _buildNutritionBreakdown(),
                const SizedBox(height: 24),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        ),
      ),
    );
  }

  Color _surface(BuildContext context) => Theme.of(context).colorScheme.surface;

  Color _onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);

  Color _border(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.scanResultTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: GestureDetector(
        onTap: () => context.go('/scan'),
        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => context.go('/scan'),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodImage() {
    final l10n = AppLocalizations.of(context)!;
    final textSecondary = _mutedText(context);

    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.imageUrl != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(textSecondary, l10n);
                  },
                ),
              ),
            )
          else
            _buildPlaceholderImage(textSecondary, l10n),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded,
                      color: Colors.white, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    AppLocalizations.of(context)!.matchPercent('92'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'AI analyzed and ready to log',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Color textSecondary, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.breakfast_dining,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sampleFoodName,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodInfo() {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = _onSurface(context);
    final textSecondary = _mutedText(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.foodIdentifiedPrefix(l10n.sampleFoodName),
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _surface(context),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.20),
            ),
          ),
          child: Column(
            children: [
              Text(
                l10n.totalCalories,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedBuilder(
                animation: _metricController,
                builder: (context, child) {
                  final animatedCalories =
                      (350 * _metricController.value).round();
                  return Text(
                    '$animatedCalories ${l10n.kcal}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.portionSize}: ',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    '200g',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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

  Widget _buildQuantitySelector() {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = _onSurface(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quantity,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border(context), width: 1),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (quantity > 1) {
                      quantity--;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: const Icon(
                    Icons.remove,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBreakdown() {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = _onSurface(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nutritionFactsPerServing,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border(context), width: 1),
          ),
          child: AnimatedBuilder(
            animation: _metricController,
            builder: (context, child) {
              return Column(
                children: [
                  _buildNutritionBarRow(
                    l10n.protein,
                    '12g',
                    0.42,
                    Colors.blue,
                    _metricController.value,
                  ),
                  const SizedBox(height: 14),
                  _buildNutritionBarRow(
                    l10n.carbs,
                    '35g',
                    0.76,
                    Colors.orange,
                    _metricController.value,
                  ),
                  const SizedBox(height: 14),
                  _buildNutritionBarRow(
                    l10n.fat,
                    '18g',
                    0.50,
                    Colors.red,
                    _metricController.value,
                  ),
                  const SizedBox(height: 14),
                  _buildNutritionBarRow(
                    l10n.fiber,
                    '5g',
                    0.28,
                    Colors.green,
                    _metricController.value,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBarRow(
    String label,
    String value,
    double ratio,
    Color color,
    double animationValue,
  ) {
    final textPrimary = _onSurface(context);

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
                    color: textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio * animationValue,
            minHeight: 7,
            backgroundColor: color.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.savedToHistory),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            l10n.saveToHistory,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 1,
      surfaceColor: _surface(context),
      borderColor: _border(context),
      unselectedItemColor: _mutedText(context),
    );
  }
}
