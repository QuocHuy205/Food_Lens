import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';
import 'package:food_lens/features/history/presentation/widgets/history_list_item.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../scan/domain/entities/scan_history.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageEnterController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(profileViewModelProvider.notifier).loadProfile(uid);
        ref.read(historyViewModelProvider.notifier).loadHistory(uid);
      }
    });
  }

  void _setupAnimations() {
    // Page enter animation
    _pageEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageEnterController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageEnterController, curve: Curves.easeOut),
    );

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Start progress after page enters
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _pageEnterController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileViewModelProvider);
    final historyState = ref.watch(historyViewModelProvider);
    final profile = profileState.profile.valueOrNull;
    final scans = historyState.history.valueOrNull ?? const <ScanHistory>[];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(profile, l10n),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Greeting Card
                _buildGreetingCard(profile),
                const SizedBox(height: 20),
                // Calorie Summary Card
                _buildCalorieSummaryCard(profile, scans),
                const SizedBox(height: 20),
                // Recent Scans
                _buildRecentScans(scans),
                const SizedBox(height: 24),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(),
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

  PreferredSizeWidget _buildAppBar(
      UserProfile? profile, AppLocalizations l10n) {
    final initials = _resolveDisplayName(profile).isNotEmpty
        ? _resolveDisplayName(profile).substring(0, 1).toUpperCase()
        : 'U';

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.appName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: ClipOval(
                child:
                    profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty
                        ? Image.network(
                            profile.photoUrl!,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(UserProfile? profile) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = _onSurface(context);
    final textSecondary = _mutedText(context);

    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final localeName = Localizations.localeOf(context).toLanguageTag();
        final salutation = _buildSalutation(l10n, now.hour);
        final dateText = DateFormat('EEEE, d MMMM y', localeName).format(now);
        final timeText = DateFormat('HH:mm:ss', localeName).format(now);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF22372B), Color(0xFF17241D)]
                  : const [Color(0xFFF6FBF4), Color(0xFFE4F3E7)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark ? _border(context) : const Color(0xFFD7E8DA),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salutation,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateText,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : const Color(0xFFD9E8DB),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF9CE3A6)
                                      : const Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeText,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF244D28),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFD8E8DB),
                  ),
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: isDark ? Colors.white : const Color(0xFF2E7D32),
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildSalutation(AppLocalizations l10n, int hour) {
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  int _resolveDailyCalorieTarget(UserProfile? profile) {
    final savedTarget = profile?.dailyCalorieTarget;
    if (savedTarget != null && savedTarget > 0) {
      return savedTarget.round();
    }

    if (profile == null) {
      return 0;
    }

    return _calculateTdeeFromProfile(profile);
  }

  int _calculateTdeeFromProfile(UserProfile profile) {
    final isMale = profile.gender.toLowerCase() == 'male';
    final activityMultiplier = switch (profile.activityLevel.toLowerCase()) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'very active' || 'very_active' => 1.9,
      _ => 1.375,
    };

    final bmr = isMale
        ? 10 * profile.weight + 6.25 * profile.height - 5 * profile.age + 5
        : 10 * profile.weight + 6.25 * profile.height - 5 * profile.age - 161;

    return (bmr * activityMultiplier).round();
  }

  String _resolveDisplayName(UserProfile? profile) {
    final profileName = profile?.name.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName.split(' ').first;
    }

    final authUser = FirebaseAuth.instance.currentUser;
    final authName = authUser?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName.split(' ').first;
    }

    final email = authUser?.email;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'User';
  }

  Widget _buildCalorieSummaryCard(
      UserProfile? profile, List<ScanHistory> scans) {
    final l10n = AppLocalizations.of(context)!;
    final consumedCalories = _calculateTodayCalories(scans);
    final goalCalories = _resolveDailyCalorieTarget(profile);
    final consumedCaloriesText = _formatCalories(consumedCalories);
    final hasGoalCalories = goalCalories > 0;
    final progress =
        hasGoalCalories ? (consumedCalories / goalCalories).clamp(0, 1) : 0.0;
    final remainingCalories = hasGoalCalories
        ? (goalCalories - consumedCalories).clamp(0, double.infinity).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -44,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dailyCalories,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      l10n.aiInsight,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    final animatedProgress =
                        progress * _progressController.value;
                    final animatedCalories =
                        (consumedCalories * _progressController.value).round();

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 164,
                          height: 164,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                              width: 1,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 148,
                          height: 148,
                          child: CircularProgressIndicator(
                            value: animatedProgress,
                            strokeWidth: 12,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.20),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$animatedCalories',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              hasGoalCalories
                                  ? '/ $goalCalories ${l10n.kcal}'
                                  : l10n.dailyCalories,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCalorieStatChip(
                      label: l10n.consumed,
                      value: '$consumedCaloriesText ${l10n.kcal}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCalorieStatChip(
                      label: l10n.remaining,
                      value: '$remainingCalories ${l10n.kcal}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCalorieStatChip(
                      label: l10n.goal,
                      value: hasGoalCalories
                          ? '$goalCalories ${l10n.kcal}'
                          : '-- ${l10n.kcal}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStatChip({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _calculateTodayCalories(List<ScanHistory> scans) {
    final now = DateTime.now();
    return scans
        .where((scan) =>
            scan.createdAt.year == now.year &&
            scan.createdAt.month == now.month &&
            scan.createdAt.day == now.day)
        .fold<double>(0.0, (sum, scan) => sum + scan.calories);
  }

  Widget _buildRecentScans(List<ScanHistory> scans) {
    final textPrimary = _onSurface(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentScans,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/history'),
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (scans.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border(context), width: 1),
            ),
            child: Text(
              _localizedMessage(
                vi: 'Chưa có lịch sử quét',
                en: 'No scan history yet',
              ),
              style: TextStyle(
                color: _mutedText(context),
                fontSize: 13,
              ),
            ),
          )
        else
          ...scans.take(3).map((scan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HistoryListItem(
                imageUrl: scan.imageUrl,
                name: scan.foodName,
                time: DateFormat('HH:mm').format(scan.createdAt),
                calories: scan.calories.round(),
                type: '',
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () => context.go('/scan'),
      elevation: 6,
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 0,
      surfaceColor: _surface(context),
      unselectedItemColor: _mutedText(context),
    );
  }

  String _localizedMessage({required String vi, required String en}) {
    return Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
  }

  String _formatCalories(double calories) => calories.round().toString();
}
