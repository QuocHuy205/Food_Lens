// User profile entity
class UserProfile {
  final String userId;
  final String email;
  final String name;
  final String? photoUrl;
  final double weight; // kg
  final double height; // cm
  final int age;
  final String gender;
  final String activityLevel;
  final String goal;
  final double? dailyCalorieTarget;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    this.dailyCalorieTarget,
    required this.createdAt,
    this.updatedAt,
  });
}
