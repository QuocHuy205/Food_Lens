// Numeric constants and magic numbers
class NumericConstants {
  // BMI categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 25.0;
  static const double bmiOverweight = 30.0;

  // Activity levels (TDEE multipliers)
  static const double activitySedentary = 1.2;
  static const double activityLight = 1.375;
  static const double activityModerate = 1.55;
  static const double activityActive = 1.725;
  static const double activityVeryActive = 1.9;

  // Calorie margins
  static const double calorieMarginLow = 0.8; // 80% is too low
  static const double calorieMarginHigh = 1.1; // 110% is too high

  // Nutrition macros (grams)
  static const double proteinPerKgLow = 1.2;
  static const double proteinPerKgHigh = 2.0;
  static const double carbsPercentage = 0.45;
  static const double fatsPercentage = 0.35;

  // AI confidence threshold
  static const double confidenceThreshold = 0.7;

  // Image upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const double imageQuality = 0.8;

  // Animation durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 1000;
}
