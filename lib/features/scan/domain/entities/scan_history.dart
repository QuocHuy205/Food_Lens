// Scan history entity
class ScanHistory {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final String imageUrl;
  final DateTime createdAt;
  final double? quantity; // grams or pieces

  ScanHistory({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.imageUrl,
    required this.createdAt,
    this.quantity,
  });
}
