// Scan result entity (from AI)
class ScanResult {
  final String foodName;
  final String? foodNameVi;
  final double estimatedCalories;
  final double confidence;
  final DateTime scannedAt;
  final String? imageUrl;

  const ScanResult({
    required this.foodName,
    this.foodNameVi,
    required this.estimatedCalories,
    required this.confidence,
    required this.scannedAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_name_vi': foodNameVi,
      'calories_estimated': estimatedCalories,
      'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
