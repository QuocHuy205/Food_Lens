# ✨ CODE QUALITY — Chuẩn viết code

---

## Giới hạn kích thước

| Đơn vị | Giới hạn |
|--------|---------|
| File | < 300 dòng |
| Function/Method | < 50 dòng |
| Class | < 200 dòng |
| Nesting | ≤ 3 cấp |
| Parameters | ≤ 4 tham số |

### Khi file quá dài → tách:
```
scan_screen.dart (quá 300 dòng)
→ scan_screen.dart          (màn hình chính, chỉ layout)
→ scan_result_card.dart     (widget kết quả)
→ scan_history_tile.dart    (widget lịch sử)
```

---

## Naming rõ ràng

```dart
// ❌ Xấu
var d = DateTime.now();
void fn1() {}
var lst = [];

// ✅ Tốt
final today = DateTime.now();
Future<void> loadScanHistory() async {}
final scanResults = <ScanHistory>[];
```

---

## Không nesting quá sâu

```dart
// ❌ Xấu — nesting 4 cấp
if (user != null) {
  if (user.profile != null) {
    if (user.profile!.tdee != null) {
      if (calories > user.profile!.tdee!) {
        showWarning();
      }
    }
  }
}

// ✅ Tốt — early return
if (user == null) return;
if (user.profile == null) return;
final tdee = user.profile!.tdee;
if (tdee == null) return;
if (calories > tdee) showWarning();
```

---

## Const và final

```dart
// Dùng const khi có thể
const padding = EdgeInsets.all(16);
const textStyle = TextStyle(fontSize: 14);

// Dùng final cho biến chỉ gán 1 lần
final userId = FirebaseAuth.instance.currentUser!.uid;
```

---

## Extension thay vì helper function lẻ

```dart
// core/extensions/datetime_ext.dart
extension DateTimeExt on DateTime {
  String toDisplayDate() => DateFormat('dd/MM/yyyy').format(this);
  String toDisplayTime() => DateFormat('HH:mm').format(this);
  bool isToday() => DateFormat('yyyyMMdd').format(this) ==
      DateFormat('yyyyMMdd').format(DateTime.now());
}

// Dùng:
final label = scan.eatenDate.toDisplayDate(); // ✅ Đẹp hơn
```

---

## Model phải có copyWith, toJson, fromJson

```dart
class ScanHistory {
  final String id;
  final String userId;
  final String foodName;
  final double totalCalories;
  final DateTime createdAt;

  const ScanHistory({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.totalCalories,
    required this.createdAt,
  });

  // Factory từ Firestore
  factory ScanHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanHistory(
      id: doc.id,
      userId: data['userId'] as String,
      foodName: data['foodName'] as String,
      totalCalories: (data['totalCalories'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert sang Firestore
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'foodName': foodName,
    'totalCalories': totalCalories,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  // Copy với thay đổi
  ScanHistory copyWith({
    String? foodName,
    double? totalCalories,
  }) => ScanHistory(
    id: id,
    userId: userId,
    foodName: foodName ?? this.foodName,
    totalCalories: totalCalories ?? this.totalCalories,
    createdAt: createdAt,
  );
}
```

---

## Xử lý null safety

```dart
// ❌ Xấu — force unwrap
final name = user!.displayName!;

// ✅ Tốt — null check
final name = user?.displayName ?? 'Người dùng';

// ✅ Tốt — null check với xử lý lỗi
if (user == null) {
  throw const AuthFailure('Chưa đăng nhập');
}
```
