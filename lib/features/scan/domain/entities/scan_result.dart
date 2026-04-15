// Scan result entity (from AI)
class ScanResult {
  final String foodName;
  final double estimatedCalories;
  final double confidence;
  final DateTime scannedAt;
  final String? imageUrl;

  ScanResult({
    required this.foodName,
    required this.estimatedCalories,
    required this.confidence,
    required this.scannedAt,
    this.imageUrl,
  });
}
