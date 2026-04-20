import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/animated_widgets.dart';
import 'package:food_lens/core/services/cloudinary_service.dart';
import 'dart:io';

import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageEnterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  String? selectedGender;
  String? selectedActivityLevel;
  String? selectedGoal;
  bool _seededFromProfile = false;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    nameController = TextEditingController();
    ageController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    selectedGender = 'male';
    selectedActivityLevel = 'moderate';
    selectedGoal = 'maintain';

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
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profileViewModelProvider);
    final currentProfile = state.profile.valueOrNull;

    if (currentProfile != null && !_seededFromProfile) {
      _seedControllers(currentProfile);
      _seededFromProfile = true;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context),
          body: currentProfile == null && state.profile.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInWidget(
                        delay: const Duration(milliseconds: 80),
                        child: _buildAvatarSection(context),
                      ),
                      const SizedBox(height: 20),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 100),
                        child: _buildSectionTitle(l10n.personalInformation),
                      ),
                      const SizedBox(height: 12),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 150),
                        child: _buildTextField(l10n.fullName, nameController),
                      ),
                      const SizedBox(height: 12),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 200),
                        child: _buildTextField(l10n.age, ageController,
                            isNumeric: true, onChanged: (_) => setState(() {})),
                      ),
                      const SizedBox(height: 12),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 250),
                        child: _buildDropdownField(
                          l10n.gender,
                          selectedGender,
                          [
                            MapEntry('male', l10n.male),
                            MapEntry('female', l10n.female),
                          ],
                          (value) => setState(() => selectedGender = value),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 300),
                        child: _buildSectionTitle(l10n.physicalMeasurements),
                      ),
                      const SizedBox(height: 12),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 350),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                l10n.heightCm,
                                heightController,
                                isNumeric: true,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                l10n.weightKg,
                                weightController,
                                isNumeric: true,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                l10n.bmi,
                                bmi.toStringAsFixed(1),
                                _getBMIStatus(bmi, l10n),
                                _getBMIColor(bmi),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                l10n.tdee,
                                '${tdee.toStringAsFixed(0)} kcal',
                                l10n.basedOnActivity(
                                  _activityLevelLocalizedLabel(
                                    l10n,
                                    selectedActivityLevel,
                                  ),
                                ),
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 500),
                        child: _buildSectionTitle(l10n.activityGoal),
                      ),
                      const SizedBox(height: 12),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 550),
                        child: _buildDropdownField(
                          l10n.activityLevel,
                          selectedActivityLevel,
                          [
                            MapEntry('sedentary', l10n.sedentary),
                            MapEntry('light', l10n.light),
                            MapEntry('moderate', l10n.moderate),
                            MapEntry('active', l10n.active),
                            MapEntry('very_active', l10n.veryActive),
                          ],
                          (value) =>
                              setState(() => selectedActivityLevel = value),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 600),
                        child: _buildDropdownField(
                          l10n.goal,
                          selectedGoal,
                          [
                            MapEntry('lose_weight', l10n.loseWeight),
                            MapEntry('maintain', l10n.maintain),
                            MapEntry('gain_weight', l10n.gainWeight),
                          ],
                          (value) => setState(() => selectedGoal = value),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInWidget(
                        delay: const Duration(milliseconds: 650),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.go('/profile'),
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.discard,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: state.isSaving ? null : _saveProfile,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2E7D32),
                                        Color(0xFF388E3C)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: state.isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            l10n.saveChanges,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.editProfileTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        onPressed: () => context.go('/profile'),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initials = nameController.text.trim().isNotEmpty
        ? nameController.text.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? Image.network(
                          _avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ),
              GestureDetector(
                onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _isUploadingAvatar
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapCameraChangeAvatar,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      onTap: () {
        if (!isNumeric) return;

        final text = controller.text.trim();
        if (text == '0' || text == '0.0' || text == '0.00') {
          controller.clear();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<MapEntry<String, String>> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item.key,
            child: Text(item.value),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(label),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    String subtitle,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  double get bmi {
    final height = double.tryParse(heightController.text) ?? 0;
    final weight = double.tryParse(weightController.text) ?? 0;
    if (height == 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  double get tdee {
    final weight = double.tryParse(weightController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;
    final age = double.tryParse(ageController.text) ?? 0;
    if (weight == 0 || height == 0 || age == 0) return 0;

    final bmr = selectedGender == 'male'
        ? 10 * weight + 6.25 * height - 5 * age + 5
        : 10 * weight + 6.25 * height - 5 * age - 161;

    final multiplier = switch (selectedActivityLevel) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'very_active' => 1.9,
      _ => 1.375,
    };

    return bmr * multiplier;
  }

  String _getBMIStatus(double value, AppLocalizations l10n) {
    if (value < 18.5) return l10n.underweight;
    if (value < 25) return l10n.normalWeight;
    if (value < 30) return l10n.overweight;
    return l10n.obese;
  }

  Color _getBMIColor(double value) {
    if (value < 18.5) return Colors.blue;
    if (value < 25) return Colors.green;
    if (value < 30) return Colors.orange;
    return Colors.red;
  }

  void _seedControllers(UserProfile profile) {
    nameController.text = profile.name;
    ageController.text = profile.age.toString();
    heightController.text = profile.height.toStringAsFixed(0);
    weightController.text = profile.weight.toStringAsFixed(0);
    _avatarUrl = profile.photoUrl;
    selectedGender = _genderCode(profile.gender);
    selectedActivityLevel = _activityLevelCode(profile.activityLevel);
    selectedGoal = _goalCode(profile.goal);
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);

    final uploadedUrl = await CloudinaryService.uploadImage(File(picked.path));

    if (!mounted) return;

    setState(() => _isUploadingAvatar = false);

    if (uploadedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.uploadAvatarFailed),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _avatarUrl = uploadedUrl);
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final oldProfile = ref.read(profileViewModelProvider).profile.valueOrNull;
    if (oldProfile == null) return;

    final updated = UserProfile(
      userId: uid,
      email: oldProfile.email,
      name: nameController.text.trim().isEmpty
          ? oldProfile.name
          : nameController.text.trim(),
      photoUrl: _avatarUrl,
      age: int.tryParse(ageController.text) ?? oldProfile.age,
      height: double.tryParse(heightController.text) ?? oldProfile.height,
      weight: double.tryParse(weightController.text) ?? oldProfile.weight,
      gender: _genderDisplay(selectedGender) ?? oldProfile.gender,
      activityLevel: _activityLevelDisplay(selectedActivityLevel) ??
          oldProfile.activityLevel,
      goal: _goalDisplay(selectedGoal) ?? oldProfile.goal,
      dailyCalorieTarget: tdee,
      createdAt: oldProfile.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileViewModelProvider.notifier).updateProfile(updated);

    if (!mounted) return;

    final latestState = ref.read(profileViewModelProvider);
    if (latestState.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.go('/profile');
    }
  }

  String _genderCode(String value) {
    return switch (value.toLowerCase()) {
      'female' => 'female',
      _ => 'male',
    };
  }

  String _activityLevelCode(String value) {
    return switch (value.toLowerCase()) {
      'sedentary' => 'sedentary',
      'light' => 'light',
      'active' => 'active',
      'very active' => 'very_active',
      _ => 'moderate',
    };
  }

  String _goalCode(String value) {
    return switch (value.toLowerCase()) {
      'lose weight' => 'lose_weight',
      'gain weight' => 'gain_weight',
      _ => 'maintain',
    };
  }

  String? _genderDisplay(String? code) {
    return switch (code) {
      'male' => 'Male',
      'female' => 'Female',
      _ => null,
    };
  }

  String? _activityLevelDisplay(String? code) {
    return switch (code) {
      'sedentary' => 'Sedentary',
      'light' => 'Light',
      'moderate' => 'Moderate',
      'active' => 'Active',
      'very_active' => 'Very Active',
      _ => null,
    };
  }

  String? _goalDisplay(String? code) {
    return switch (code) {
      'lose_weight' => 'Lose Weight',
      'maintain' => 'Maintain',
      'gain_weight' => 'Gain Weight',
      _ => null,
    };
  }

  String _activityLevelLocalizedLabel(
    AppLocalizations l10n,
    String? code,
  ) {
    return switch (code) {
      'sedentary' => l10n.sedentary,
      'light' => l10n.light,
      'moderate' => l10n.moderate,
      'active' => l10n.active,
      'very_active' => l10n.veryActive,
      _ => l10n.moderate,
    };
  }
}
