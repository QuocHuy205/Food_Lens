import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.userId,
    required super.name,
    required super.weight,
    required super.height,
    required super.age,
    required super.isMale,
    super.dailyCalorieTarget,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      isMale: json['isMale'] as bool,
      dailyCalorieTarget: json['dailyCalorieTarget'] != null
          ? (json['dailyCalorieTarget'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'isMale': isMale,
      'dailyCalorieTarget': dailyCalorieTarget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
