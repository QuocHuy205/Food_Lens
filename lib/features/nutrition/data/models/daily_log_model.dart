import '../../domain/entities/daily_log.dart';

class DailyLogModel extends DailyLog {
  DailyLogModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.totalCalories,
    required super.totalProtein,
    required super.totalCarbs,
    required super.totalFats,
    super.scanIds,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFats: (json['totalFats'] as num).toDouble(),
      scanIds: List<String>.from(json['scanIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'scanIds': scanIds,
    };
  }
}
