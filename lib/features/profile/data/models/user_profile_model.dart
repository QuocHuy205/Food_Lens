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
      name: (json['full_name'] ?? json['name'] ?? '') as String,
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

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      weight: entity.weight,
      height: entity.height,
      age: entity.age,
      gender: entity.gender,
      activityLevel: entity.activityLevel,
      goal: entity.goal,
      dailyCalorieTarget: entity.dailyCalorieTarget,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'full_name': name,
      'photoUrl': photoUrl,
      'weight_kg': weight,
      'height_cm': height,
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
