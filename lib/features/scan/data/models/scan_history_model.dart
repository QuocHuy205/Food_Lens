import '../../domain/entities/scan_history.dart';

class ScanHistoryModel extends ScanHistory {
  ScanHistoryModel({
    required super.id,
    required super.userId,
    required super.foodName,
    required super.calories,
    required super.imageUrl,
    required super.createdAt,
    super.quantity,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      foodName: json['foodName'] as String,
      calories: (json['calories'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'quantity': quantity,
    };
  }
}
