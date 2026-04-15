// Extension methods for DateTime
extension DateTimeExt on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Get day name (Monday, Tuesday, etc.)
  String get dayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
