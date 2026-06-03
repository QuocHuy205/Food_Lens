import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_history.dart';
import '../providers/scan_provider.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key, this.imagePath, this.prediction});

  final String? imagePath;
  final Map<String, dynamic>? prediction;

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen>
    with TickerProviderStateMixin {
  int quantity = 100; // grams (default)
  late final TextEditingController _quantityController;
  late AnimationController _slideController;
  late AnimationController _metricController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: quantity.toString());
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
    _quantityController.dispose();
    _slideController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  void _setQuantity(int value) {
    final clamped = value.clamp(1, 9999);
    setState(() {
      quantity = clamped;
      _quantityController.text = clamped.toString();
      _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length),
      );
    });
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
      centerTitle: true,
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
    final hasLocalFile =
        widget.imagePath != null && File(widget.imagePath!).existsSync();
    final confidence =
        (widget.prediction?['confidence'] as num?)?.toDouble() ?? 0.92;

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
          if (hasLocalFile)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(textSecondary, l10n);
                  },
                ),
              ),
            )
          else if (widget.imagePath != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.imagePath!,
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
                    AppLocalizations.of(context)!
                        .matchPercent('${(confidence * 100).round()}'),
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
    final prediction = widget.prediction;
    final foodName = (prediction?['food_name_vi'] as String?) ??
        (prediction?['food_name'] as String?) ??
        l10n.sampleFoodName;
    final baseCalories =
        (prediction?['calories_estimated'] as num?)?.toDouble() ?? 350.0;

    // Tính calories dựa vào quantity (mặc định 100g)
    final calculatedCalories =
        (baseCalories * quantity / 100).round().toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.foodIdentifiedPrefix(foodName),
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
                      (calculatedCalories * _metricController.value).round();
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
                  Text(
                    '${quantity}g',
                    style: const TextStyle(
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
                  _setQuantity(quantity - 10);
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '100',
                      hintStyle: TextStyle(
                        color: textPrimary.withValues(alpha: 0.35),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setState(() => quantity = parsed);
                      }
                    },
                    onSubmitted: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        _setQuantity(parsed);
                      } else {
                        _quantityController.text = quantity.toString();
                      }
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _setQuantity(quantity + 10);
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
    final prediction = widget.prediction ?? {};
    final baseCalories =
        (prediction['calories_estimated'] as num?)?.toDouble() ?? 350.0;
    final calculatedCalories =
        (baseCalories * quantity / 100).round().toDouble();
    final foodName = (prediction['food_name_vi'] as String?) ??
        (prediction['food_name'] as String?) ??
        l10n.sampleFoodName;
    final imageUrl =
        (prediction['image_url'] as String?) ?? widget.imagePath ?? '';

    return GestureDetector(
      onTap: _isSaving
          ? null
          : () async {
              await _saveScanHistory(foodName, calculatedCalories, imageUrl);
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
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
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

  Future<void> _saveScanHistory(
    String foodName,
    double calories,
    String imageUrl,
  ) async {
    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw StateError('Người dùng chưa đăng nhập');
      }

      final history = ScanHistory(
        id: const Uuid().v4(),
        userId: userId,
        foodName: foodName,
        calories: calories.round().toDouble(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        quantity: quantity.toDouble(),
      );

      final viewModel = ref.read(scanViewModelProvider.notifier);
      await viewModel.saveScanHistory(history);

      final errorMessage = ref.read(scanViewModelProvider).errorMessage;
      if (errorMessage != null) {
        throw StateError(errorMessage);
      }

      if (mounted) {
        final caloriesText = history.calories.round().toString();
        final quantityText = '${quantity}g';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localizedMessage(
                vi: 'Đã lưu vào lịch sử: $quantityText • $caloriesText kcal',
                en: 'Saved to history: $quantityText • $caloriesText kcal',
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu lịch sử: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 1,
      surfaceColor: _surface(context),
      unselectedItemColor: _mutedText(context),
    );
  }

  String _localizedMessage({required String vi, required String en}) {
    return Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
  }
}
