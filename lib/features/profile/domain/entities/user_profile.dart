// User profile entity
class UserProfile {
  final String userId;
  final String name;
  final double weight; // kg
  final double height; // cm
  final int age;
  final bool isMale;
  final double? dailyCalorieTarget;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.isMale,
    this.dailyCalorieTarget,
    required this.createdAt,
    this.updatedAt,
  });
}
