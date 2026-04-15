// Format and convert calorie-related values
class CalorieFormatter {
  /// Format calories with suffix (e.g., 2500 kcal)
  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} kcal';
  }

  /// Format grams with suffix
  static String formatGrams(double grams) {
    return '${grams.toStringAsFixed(1)}g';
  }

  /// Calculate percentage of daily intake
  static String formatPercentage(double current, double total) {
    final percentage = (current / total * 100);
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Format daily summary (e.g., "2500 / 3000 kcal")
  static String formatDailySummary(double consumed, double target) {
    return '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} kcal';
  }

  /// Get color based on calorie percentage
  static String getCalorieStatus(double current, double target) {
    final percentage = current / target;
    if (percentage < 0.8) return 'under';
    if (percentage <= 1.1) return 'perfect';
    return 'over';
  }
}
