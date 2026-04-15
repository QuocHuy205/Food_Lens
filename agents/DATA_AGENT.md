# 🗄️ DATA AGENT — Firestore Schema & Data Strategy

> File quan trọng nhất. Đọc kỹ trước khi code bất kỳ thứ gì liên quan đến database.

---

## Mapping ERD → Firestore Collections

Database gốc dùng SQL (ERD với UUID), ta convert sang Firestore (NoSQL):

| SQL Table | Firestore Collection | Ghi chú |
|-----------|---------------------|---------|
| USERS | `/users/{userId}` | userId = Firebase Auth UID |
| USER_PROFILES | `/users/{userId}` (merged) | Gộp vào user doc |
| FOOD_CATEGORIES | `/food_categories/{categoryId}` | Static data, ít thay đổi |
| FOODS | `/foods/{foodId}` | Static data, seed 1 lần |
| SCAN_HISTORY | `/users/{userId}/scans/{scanId}` | Subcollection |
| DAILY_NUTRITION_LOG | `/users/{userId}/daily_logs/{date}` | date = "2026-04-14" |
| NUTRITION_RECOMMENDATIONS | `/users/{userId}/recommendations/{recId}` | Subcollection |
| AI_MODEL_LOGS | `/scans/{scanId}/ai_logs/{logId}` | Chỉ dùng debug |

---

## Schema chi tiết từng Collection

### `/users/{userId}`

```javascript
{
  // Từ USERS table
  uid: "firebase-auth-uid",          // string — Firebase UID
  fullName: "Nguyễn Văn A",          // string
  email: "a@gmail.com",              // string
  avatarUrl: "https://...",          // string | null
  createdAt: Timestamp,              // Timestamp

  // Từ USER_PROFILES table (merged)
  weightKg: 65.0,                    // number | null
  heightCm: 170.0,                   // number | null
  age: 22,                           // number | null
  gender: "male",                    // "male" | "female" | null
  activityLevel: "moderate",        // "sedentary"|"light"|"moderate"|"active"|"very_active"
  tdeeCalories: 2200.0,              // number | null — tính tự động
  goal: "maintain",                  // "lose"|"maintain"|"gain"
  calorieGoal: 2000,                 // number — mục tiêu calo/ngày
  profileUpdatedAt: Timestamp
}
```

### `/food_categories/{categoryId}`

```javascript
{
  id: "cat_001",
  name: "Vietnamese",                // string (English)
  nameVi: "Món Việt",               // string (Vietnamese)
  iconUrl: "https://..."
}
```

### `/foods/{foodId}`

```javascript
{
  id: "food_001",
  categoryId: "cat_001",            // ref to food_categories
  name: "Pho Bo",
  nameVi: "Phở bò",
  caloriesPer100g: 75.0,            // calo / 100g
  proteinG: 7.5,
  carbsG: 9.0,
  fatG: 1.5,
  fiberG: 0.5,
  sodiumMg: 400.0,
  imageUrl: "https://...",
  isVietnamese: true
}
```

### `/users/{userId}/scans/{scanId}`

```javascript
{
  id: "scan_abc123",
  userId: "firebase-uid",
  foodId: "food_001",               // ref to /foods
  foodName: "Phở bò",               // denormalized — tránh join
  imageUrl: "https://cloudinary.com/...",
  portionGrams: 400.0,
  totalCalories: 300.0,
  confidenceScore: 0.92,            // 0.0 → 1.0
  mealType: "lunch",                // "breakfast"|"lunch"|"dinner"|"snack"
  eatenDate: "2026-04-14",          // string YYYY-MM-DD — dễ query
  eatenTime: "12:30",               // string HH:mm
  createdAt: Timestamp,

  // AI info (từ AI_MODEL_LOGS — merge để đơn giản)
  aiModelVersion: "v1.0",
  aiTopPredictions: [
    { name: "Phở bò", confidence: 0.92 },
    { name: "Bún bò", confidence: 0.05 },
    { name: "Hủ tiếu", confidence: 0.03 }
  ],
  aiInferenceTimeMs: 234.5
}
```

### `/users/{userId}/daily_logs/{date}`

```javascript
// Document ID = "2026-04-14" (YYYY-MM-DD)
{
  userId: "firebase-uid",
  logDate: "2026-04-14",
  totalCalories: 1850.0,
  totalProteinG: 75.0,
  totalCarbsG: 220.0,
  totalFatG: 60.0,
  calorieGoal: 2000.0,
  updatedAt: Timestamp
}
```

### `/users/{userId}/recommendations/{recId}`

```javascript
{
  id: "rec_001",
  userId: "firebase-uid",
  title: "Hôm nay bạn còn 500 calo",
  description: "Bạn có thể ăn thêm 1 bát cơm tấm vào buổi tối.",
  recommendationType: "calorie_reminder", // "calorie_reminder"|"nutrition_tip"|"goal_progress"
  targetCalories: 500.0,
  isActive: true,
  createdAt: Timestamp
}
```

---

## Query thường dùng

### Lấy lịch sử scan theo ngày:
```dart
FirebaseFirestore.instance
  .collection('users/$userId/scans')
  .where('eatenDate', isEqualTo: '2026-04-14')
  .orderBy('createdAt', descending: true)
  .limit(20)
  .get();
```

### Lấy daily log của tuần:
```dart
// Tạo list 7 ngày rồi get từng doc (Firestore không support range query trên string ID tốt)
final dates = List.generate(7, (i) =>
  DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: i))));

final futures = dates.map((date) =>
  FirebaseFirestore.instance.doc('users/$userId/daily_logs/$date').get());

final docs = await Future.wait(futures);
```

### Lấy stats 30 ngày:
```dart
final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
FirebaseFirestore.instance
  .collection('users/$userId/scans')
  .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
  .orderBy('createdAt', descending: true)
  .get();
```

---

## Indexes cần tạo trong Firebase Console

Vào Firebase Console → Firestore → Indexes → Add composite index:

| Collection | Fields | Order |
|-----------|--------|-------|
| `users/{uid}/scans` | `eatenDate` ASC, `createdAt` DESC | Compound |
| `users/{uid}/scans` | `mealType` ASC, `createdAt` DESC | Compound |

> Firebase thường tự nhắc tạo index khi query thất bại — copy link trong log là xong.

---

## Offline Strategy

Firestore tự động cache dữ liệu offline. Enable:

```dart
// main.dart — gọi sau Firebase.initializeApp()
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Kết quả: App hoạt động offline, sync tự động khi có mạng.

---

## Seed data Foods (chạy 1 lần)

Tạo file `scripts/seed_foods.dart`:

```dart
final foods = [
  {'nameVi': 'Phở bò', 'name': 'Pho Bo', 'caloriesPer100g': 75.0, 'isVietnamese': true},
  {'nameVi': 'Cơm tấm', 'name': 'Com Tam', 'caloriesPer100g': 160.0, 'isVietnamese': true},
  {'nameVi': 'Bánh mì', 'name': 'Banh Mi', 'caloriesPer100g': 265.0, 'isVietnamese': true},
  {'nameVi': 'Bún bò Huế', 'name': 'Bun Bo Hue', 'caloriesPer100g': 68.0, 'isVietnamese': true},
  {'nameVi': 'Gỏi cuốn', 'name': 'Goi Cuon', 'caloriesPer100g': 89.0, 'isVietnamese': true},
  {'nameVi': 'Cơm chiên', 'name': 'Fried Rice', 'caloriesPer100g': 190.0, 'isVietnamese': false},
  {'nameVi': 'Trứng ốp la', 'name': 'Fried Egg', 'caloriesPer100g': 196.0, 'isVietnamese': false},
  {'nameVi': 'Salad', 'name': 'Salad', 'caloriesPer100g': 15.0, 'isVietnamese': false},
];
```

---

## Security Rules (Firestore)

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User chỉ đọc/ghi data của mình
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /scans/{scanId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /daily_logs/{date} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /recommendations/{recId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if false; // chỉ server được ghi
      }
    }

    // Foods và categories: mọi người đọc được, không ai ghi được
    match /foods/{foodId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    match /food_categories/{catId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```
