// Daily nutrition log entity
class DailyLog {
  final String id;
  final String userId;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final List<String> scanIds; // Reference to scans

  DailyLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    this.scanIds = const [],
  });
}
