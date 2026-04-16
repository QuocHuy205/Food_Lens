import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF43A047);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  String? selectedGender;
  String? selectedActivityLevel;
  String? selectedGoal;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: 'John Doe');
    ageController = TextEditingController(text: '28');
    heightController = TextEditingController(text: '178');
    weightController = TextEditingController(text: '75');
    selectedGender = 'Male';
    selectedActivityLevel = 'Moderate';
    selectedGoal = 'Maintain';
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
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

    // Mifflin-St Jeor equation
    double bmr;
    if (selectedGender == 'Male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Activity multiplier
    double activityMultiplier = 1.375;
    switch (selectedActivityLevel) {
      case 'Sedentary':
        activityMultiplier = 1.2;
        break;
      case 'Light':
        activityMultiplier = 1.375;
        break;
      case 'Moderate':
        activityMultiplier = 1.55;
        break;
      case 'Active':
        activityMultiplier = 1.725;
        break;
      case 'Very Active':
        activityMultiplier = 1.9;
        break;
    }

    return bmr * activityMultiplier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Personal Info Section ───────────────
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 12),
            _buildTextField('Full Name', nameController),
            const SizedBox(height: 12),
            _buildTextField('Age', ageController, isNumeric: true),
            const SizedBox(height: 12),
            _buildDropdownField('Gender', selectedGender, ['Male', 'Female'],
                (value) {
              setState(() => selectedGender = value);
            }),
            const SizedBox(height: 24),
            // ── Physical Measurements ───────────────
            _buildSectionTitle('Physical Measurements'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Height (cm)', heightController,
                      isNumeric: true, onChanged: (_) {
                    setState(() {});
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('Weight (kg)', weightController,
                      isNumeric: true, onChanged: (_) {
                    setState(() {});
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ── BMI Display ─────────────────────────
            _buildInfoCard(
              'BMI',
              '${bmi.toStringAsFixed(1)}',
              _getBMIStatus(bmi),
              _getBMIColor(bmi),
            ),
            const SizedBox(height: 12),
            // ── TDEE Display ────────────────────────
            _buildInfoCard(
              'Daily Calorie Needs (TDEE)',
              '${tdee.toStringAsFixed(0)} kcal',
              'Based on ${selectedActivityLevel?.toLowerCase()} activity',
              Colors.blue,
            ),
            const SizedBox(height: 24),
            // ── Activity & Goal ─────────────────────
            _buildSectionTitle('Activity & Goal'),
            const SizedBox(height: 12),
            _buildDropdownField('Activity Level', selectedActivityLevel, [
              'Sedentary',
              'Light',
              'Moderate',
              'Active',
              'Very Active'
            ], (value) {
              setState(() => selectedActivityLevel = value);
            }),
            const SizedBox(height: 12),
            _buildDropdownField('Goal', selectedGoal,
                ['Lose Weight', 'Maintain', 'Gain Weight'], (value) {
              setState(() => selectedGoal = value);
            }),
            const SizedBox(height: 24),
            // ── Action Buttons ──────────────────────
            Row(
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
                      child: const Center(
                        child: Text(
                          'Discard',
                          style: TextStyle(
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
                    onTap: _saveProfile,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: GestureDetector(
        onTap: () => context.go('/profile'),
        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
    List<String> items,
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
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
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

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _saveProfile() async {
    setState(() => isSaving = true);
    // Simulate save delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500)).then((_) {
        context.go('/profile');
      });
    }
  }
}
