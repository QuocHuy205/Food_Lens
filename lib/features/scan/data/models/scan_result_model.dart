import '../../domain/entities/scan_result.dart';

class ScanResultModel extends ScanResult {
  final String? foodNameVi;
  final double? portionGrams;
  final Map<String, dynamic>? nutrition;
  final List<dynamic>? topPredictions;
  final String? aiModelVersion;
  final double? inferenceTimeMs;

  const ScanResultModel({
    required super.foodName,
    required super.estimatedCalories,
    required super.confidence,
    required super.scannedAt,
    super.imageUrl,
    this.foodNameVi,
    this.portionGrams,
    this.nutrition,
    this.topPredictions,
    this.aiModelVersion,
    this.inferenceTimeMs,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      foodName: json['food_name'] as String? ?? 'Unknown Food',
      foodNameVi: json['food_name_vi'] as String?,
      estimatedCalories:
          (json['calories_estimated'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      scannedAt: DateTime.now(),
      imageUrl: json['image_url'] as String?,
      portionGrams: (json['portion_grams'] as num?)?.toDouble(),
      nutrition: json['nutrition'] as Map<String, dynamic>?,
      topPredictions: json['top_predictions'] as List<dynamic>?,
      aiModelVersion: json['model_version'] as String?,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_name_vi': foodNameVi,
      'calories_estimated': estimatedCalories,
      'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
      'image_url': imageUrl,
      'portion_grams': portionGrams,
      'nutrition': nutrition,
      'top_predictions': topPredictions,
      'model_version': aiModelVersion,
      'inference_time_ms': inferenceTimeMs,
    };
  }
}
