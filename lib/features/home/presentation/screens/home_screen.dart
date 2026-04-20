import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

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
  late Animation<double> _progressWidth;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(profileViewModelProvider.notifier).loadProfile(uid);
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
      duration: const Duration(milliseconds: 800),
    );
    _progressWidth = Tween<double>(begin: 0.0, end: 0.925).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
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
    final profile = profileState.profile.valueOrNull;

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
                _buildCalorieSummaryCard(),
                const SizedBox(height: 20),
                // Recent Scans
                _buildRecentScans(),
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
      centerTitle: false,
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
    final displayName = _resolveDisplayName(profile);
    final formattedDate = DateFormat('d MMMM y').format(DateTime.now());
    final hour = DateTime.now().hour;
    final salutation = hour < 12
        ? l10n.goodMorning
        : hour < 18
            ? l10n.goodAfternoon
            : l10n.goodEvening;
    final focusLabel = hour < 11
        ? l10n.focusNutritiousBreakfast
        : hour < 16
            ? l10n.focusBalancedLunch
            : l10n.focusLightDinner;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF243A2D), Color(0xFF1E3226)]
              : const [Color(0xFFEDF8EF), Color(0xFFD9F0DD)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? _border(context) : const Color(0xFFCDE5D0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$salutation, $displayName',
                        style: const TextStyle(
                          color: Color(0xFF1F5F25),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.hiName(displayName),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? _border(context) : const Color(0xFFD4E8D7),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    focusLabel,
                    style: TextStyle(
                      color: isDark ? textPrimary : const Color(0xFF245D2A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'On track',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.86),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildCalorieSummaryCard() {
    final l10n = AppLocalizations.of(context)!;
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
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            l10n.dailyCalories,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Big Number
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1,450',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/ 2,200',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          _buildProgressBar(),
          const SizedBox(height: 16),
          // Macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroItem(l10n.protein, '65g', Colors.white),
              _buildMacroItem(l10n.carbs, '180g', Colors.white),
              _buildMacroItem(l10n.fat, '45g', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Background bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Animated bar
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  height: 8,
                  width:
                      MediaQuery.of(context).size.width * _progressWidth.value,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '65% of daily goal',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScans() {
    final textPrimary = _onSurface(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
        // Scan Items
        _buildScanItem(
          'Fresh Tuna Poke Bowl',
          '340 cal',
          '${l10n.lunch} • 12:30 PM',
          Icons.ramen_dining,
        ),
        const SizedBox(height: 10),
        _buildScanItem(
          'Berry Almond Oatmeal',
          '380 cal',
          '${l10n.breakfast} • 8:15 AM',
          Icons.breakfast_dining,
        ),
        const SizedBox(height: 10),
        _buildScanItem(
          'Detox Green Juice',
          '120 cal',
          '${l10n.snack} • 3:45 PM',
          Icons.local_drink,
        ),
      ],
    );
  }

  Widget _buildScanItem(
    String title,
    String calories,
    String time,
    IconData icon,
  ) {
    final textPrimary = _onSurface(context);
    final textSecondary = _mutedText(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(context), width: 1),
      ),
      child: Row(
        children: [
          // Food Icon
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Calories
          Text(
            calories,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
      borderColor: _border(context),
      unselectedItemColor: _mutedText(context),
    );
  }
}
