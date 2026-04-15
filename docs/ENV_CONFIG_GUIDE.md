# 🔐 Environment Configuration Guide

## Cấu trúc Files & Mục đích

| File                 | Mục đích                  | Git Status    | Chứa Secrets         |
| -------------------- | ------------------------- | ------------- | -------------------- |
| `.env.example`       | 📘 Template reference     | ✅ Commit     | ❌ NO (placeholders) |
| `.env`               | 🔑 Actual secrets (local) | ❌ .gitignore | ✅ YES               |
| `app_constants.dart` | ⚙️ Non-secrets constants  | ✅ Commit     | ❌ NO                |
| `firebase.json`      | 🔥 Firebase config (auto) | ✅ Commit     | ❌ Safe              |

---

## ⚡ Workflow

### 1️⃣ **Dev Setup (First Time)**

```bash
# Copy template
cp .env.example .env

# Edit with YOUR actual values
# nano .env  (or use IDE)
# CLOUDINARY_CLOUD_NAME=your-actual-cloud-name
# CLOUDINARY_UPLOAD_PRESET=your-actual-preset
# FIREBASE_API_KEY=your-actual-key
```

### 2️⃣ **App Startup (main.dart)**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env at startup
  await dotenv.load(fileName: ".env");

  // Now all dotenv.env['KEY'] calls work
  await Firebase.initializeApp(...);
  runApp(...);
}
```

### 3️⃣ **Using in Code**

**Cloudinary Service:**

```dart
// ✅ CORRECT - load from .env
final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
```

**App Constants:**

```dart
// ✅ CORRECT - non-secrets hardcoded
static const String firestoreUsersCollection = 'users';
static const String aiApiAnalyzeEndpoint = '/analyze';
```

---

## 🧪 Testing Upload Feature

### File: `lib/test/cloudinary_test.dart`

```dart
// This test screen works with .env values
// When it runs:
// 1. Loads CLOUDINARY_CLOUD_NAME from .env ✅
// 2. Loads CLOUDINARY_UPLOAD_PRESET from .env ✅
// 3. Uploads image to Cloudinary ✅

Future<void> uploadImage() async {
  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
  // ... rest of upload logic
}
```

**How to test:**

```bash
# 1. Ensure .env has valid Cloudinary values
# 2. Run app
flutter run

# 3. Navigate to Cloudinary Test Screen (or add to route)
# 4. Pick image and test upload
```

---

## ✅ Security Checklist

- [x] `.env` in `.gitignore` (secrets never committed)
- [x] `.env.example` committed (help for new devs)
- [x] `app_constants.dart` has NO secrets (only non-secrets)
- [x] `cloudinary_service.dart` loads from `.env` ✅
- [x] `cloudinary_test.dart` loads from `.env` ✅

---

## 🆘 Troubleshooting

### "ENV chưa load hoặc sai key"

```dart
// Debug: Check if .env exists and values are correct
print(dotenv.env['CLOUDINARY_CLOUD_NAME']); // Should print your value
print(dotenv.env['CLOUDINARY_UPLOAD_PRESET']); // Should print your value
```

### Upload returns 401

→ Credentials in `.env` are wrong
→ Re-copy from Cloudinary dashboard

### "Cannot find .env file"

→ Make sure `.env` is in project root (same level as pubspec.yaml)
→ Check pubspec.yaml has `flutter_dotenv` dependency

---

## 📝 Summary

✅ **You don't need to modify anything else**

- `app_constants.dart` now has ONLY non-secrets
- `cloudinary_service.dart` loads from `.env`
- `cloudinary_test.dart` loads from `.env`
- `.env` is in `.gitignore` (safe)

🎯 **When testing upload feature:**

1. Make sure `.env` has real Cloudinary values
2. Run your test screen
3. It will automatically load from `.env` ✅
