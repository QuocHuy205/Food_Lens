import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/animated_widgets.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';

import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(profileViewModelProvider.notifier).loadProfile(uid);
      }
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
    final state = ref.watch(profileViewModelProvider);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(l10n),
          body: state.profile.when(
            data: (profile) {
              if (profile == null) {
                return Center(
                  child: Text(
                    l10n.profileNoData,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    FadeInWidget(
                      delay: const Duration(milliseconds: 100),
                      child: _buildProfileHeader(profile),
                    ),
                    const SizedBox(height: 16),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                l10n.bmi,
                                _calculateBmi(profile).toStringAsFixed(1),
                                _bmiStatus(_calculateBmi(profile), l10n),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                l10n.tdee,
                                _calculateTdee(profile).toStringAsFixed(0),
                                l10n.kcalPerDay,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildSettingsItem(
                              Icons.edit,
                              l10n.editProfile,
                              l10n.updatePersonalInfo,
                              onTap: () => context.go('/edit-profile'),
                            ),
                            _buildSettingsItem(
                              Icons.settings_outlined,
                              l10n.appSettings,
                              l10n.themeAppearancePreferences,
                              onTap: () => context.push('/settings'),
                            ),
                            _buildSettingsItem(
                              Icons.lock_reset,
                              'Đổi mật khẩu',
                              'Cập nhật mật khẩu tài khoản',
                              onTap: () => context.push('/change-password'),
                            ),
                            _buildSettingsItem(
                              Icons.monitor_weight_outlined,
                              l10n.goal,
                              _localizedGoal(profile.goal, l10n),
                              onTap: () => context.go('/edit-profile'),
                            ),
                            _buildSettingsItem(
                              Icons.directions_run,
                              l10n.activityLevel,
                              _localizedActivityLevel(
                                  profile.activityLevel, l10n),
                              onTap: () => context.go('/edit-profile'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildLogoutButton(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
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

  Widget _buildProfileHeader(UserProfile profile) {
    final textPrimary = _onSurface(context);
    final textSecondary = _mutedText(context);
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim().substring(0, 1).toUpperCase()
        : 'U';

    final hasAvatar = profile.photoUrl != null && profile.photoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: _surface(context),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(44),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: hasAvatar
                  ? Image.network(
                      profile.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.profileTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    final textSecondary = _mutedText(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    final textPrimary = _onSurface(context);
    final textSecondary = _mutedText(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(context)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: textSecondary,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 4,
      surfaceColor: _surface(context),
      borderColor: _border(context),
      unselectedItemColor: _mutedText(context),
    );
  }

  Widget _buildLogoutButton() {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go('/login');
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error),
        ),
        child: Center(
          child: Text(
            l10n.logout,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateBmi(UserProfile profile) {
    if (profile.height <= 0) return 0;
    return profile.weight / ((profile.height / 100) * (profile.height / 100));
  }

  String _bmiStatus(double bmi, AppLocalizations l10n) {
    if (bmi < 18.5) return l10n.underweight;
    if (bmi < 25) return l10n.normalWeight;
    if (bmi < 30) return l10n.overweight;
    return l10n.obese;
  }

  String _localizedGoal(String goal, AppLocalizations l10n) {
    return switch (goal) {
      'Lose Weight' => l10n.loseWeight,
      'Maintain' => l10n.maintain,
      'Gain Weight' => l10n.gainWeight,
      _ => goal,
    };
  }

  String _localizedActivityLevel(String value, AppLocalizations l10n) {
    return switch (value) {
      'Sedentary' => l10n.sedentary,
      'Light' => l10n.light,
      'Moderate' => l10n.moderate,
      'Active' => l10n.active,
      'Very Active' => l10n.veryActive,
      _ => value,
    };
  }

  double _calculateTdee(UserProfile profile) {
    final base = profile.gender == 'Male'
        ? 10 * profile.weight + 6.25 * profile.height - 5 * profile.age + 5
        : 10 * profile.weight + 6.25 * profile.height - 5 * profile.age - 161;

    final multiplier = switch (profile.activityLevel) {
      'Sedentary' => 1.2,
      'Light' => 1.375,
      'Moderate' => 1.55,
      'Active' => 1.725,
      'Very Active' => 1.9,
      _ => 1.375,
    };

    return base * multiplier;
  }
}
