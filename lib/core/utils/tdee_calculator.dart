// TDEE (Total Daily Energy Expenditure) calculator
class TDEECalculator {
  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
  static double calculateBMR({
    required double weight, // kg
    required double height, // cm
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  /// Calculate TDEE based on activity level
  /// activityLevel: 1.2 (sedentary) to 1.9 (very active)
  static double calculateTDEE({
    required double bmr,
    required double activityLevel,
  }) {
    return bmr * activityLevel;
  }

  /// Calculate BMI
  static double calculateBMI({
    required double weight, // kg
    required double height, // cm
  }) {
    return weight / ((height / 100) * (height / 100));
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normalWeight';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }
}
