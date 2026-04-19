import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.userId,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.weight,
    required super.height,
    required super.age,
    required super.gender,
    required super.activityLevel,
    required super.goal,
    super.dailyCalorieTarget,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    final updatedAtValue = json['updatedAt'];

    return UserProfileModel(
      userId: (json['userId'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      photoUrl: json['photoUrl'] as String?,
      weight: ((json['weight'] ?? 0) as num).toDouble(),
      height: ((json['height'] ?? 0) as num).toDouble(),
      age: ((json['age'] ?? 0) as num).toInt(),
      gender: (json['gender'] ?? 'Male') as String,
      activityLevel: (json['activityLevel'] ?? 'Moderate') as String,
      goal: (json['goal'] ?? 'Maintain') as String,
      dailyCalorieTarget: json['dailyCalorieTarget'] != null
          ? (json['dailyCalorieTarget'] as num).toDouble()
          : null,
      createdAt: createdAtValue is String
          ? DateTime.parse(createdAtValue)
          : DateTime.now(),
      updatedAt:
          updatedAtValue is String ? DateTime.parse(updatedAtValue) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieTarget': dailyCalorieTarget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
