import '../../domain/entities/scan_result.dart';

class ScanResultModel extends ScanResult {
  ScanResultModel({
    required super.foodName,
    required super.estimatedCalories,
    required super.confidence,
    required super.scannedAt,
    super.imageUrl,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      foodName: json['food_name'] as String,
      estimatedCalories: (json['calories_estimated'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'calories_estimated': estimatedCalories,
      'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
