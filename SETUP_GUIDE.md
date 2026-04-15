# 🚀 SETUP GUIDE — Từ Zero đến Chạy Được App

> Dành cho sinh viên năm 3. Làm theo từng bước, đừng bỏ qua.

---

## Bước 1: Cài Flutter SDK

### Windows

```bash
# 1. Tải Flutter SDK tại: https://flutter.dev/docs/get-started/install/windows
# 2. Giải nén vào C:\flutter (KHÔNG để trong Program Files)
# 3. Thêm vào PATH: C:\flutter\bin

# Kiểm tra
flutter doctor
```

### macOS

```bash
brew install flutter
flutter doctor
```

### Kết quả mong muốn của `flutter doctor`:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Android Studio
[✗] Xcode (chỉ cần nếu build iOS)
[✓] VS Code
[✓] Connected device
```

---

## Bước 2: Cài Android Studio & Emulator

1. Tải Android Studio: https://developer.android.com/studio
2. Mở Android Studio → SDK Manager → Cài Android 13 (API 33)
3. Tạo Emulator: AVD Manager → Create Virtual Device → Pixel 6 → API 33
4. Khởi động emulator

```bash
# Kiểm tra device
flutter devices
# Output: Android SDK built for x86_64 (mobile) • emulator-5554
```

---

## Bước 3: Tạo Flutter Project

```bash
flutter create food_ai_app \
  --org com.vku \
  --platforms android,ios \
  --description "AI Food Recognition App"

cd food_ai_app
```

### Cấu trúc tạo ra:
```
food_ai_app/
├── android/
├── ios/
├── lib/
│   └── main.dart
├── test/
└── pubspec.yaml
```

---

## Bước 4: Setup Firebase

### 4.1 Tạo Firebase Project

1. Vào https://console.firebase.google.com
2. Nhấn **Add project** → Đặt tên: `food-ai-app`
3. Tắt Google Analytics (không cần cho demo)
4. Nhấn **Create project**

### 4.2 Thêm Android App

1. Nhấn icon Android trong project Firebase
2. **Package name:** `com.vku.food_ai_app`
3. **App nickname:** Food AI Android
4. Tải file `google-services.json`
5. Copy vào: `food_ai_app/android/app/google-services.json`

### 4.3 Sửa file Android

**`android/build.gradle`:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Thêm dòng này
    }
}
```

**`android/app/build.gradle`:**
```gradle
apply plugin: 'com.google.gms.google-services'  // Thêm ở cuối file
```

### 4.4 Enable Authentication

Firebase Console → Authentication → Sign-in method → Enable:
- ✅ Email/Password

### 4.5 Enable Firestore

Firebase Console → Firestore Database → Create database → **Start in test mode**

> ⚠️ Test mode cho phép đọc/ghi tự do trong 30 ngày — phù hợp cho demo.

---

## Bước 5: Setup Cloudinary

1. Đăng ký tại: https://cloudinary.com (miễn phí)
2. Vào **Dashboard** → Ghi lại:
   - `Cloud name`
   - `API Key`
   - `API Secret`
3. Vào **Settings → Upload → Upload presets** → Add upload preset:
   - Preset name: `food_ai_unsigned`
   - Signing mode: **Unsigned**

### Test upload:
```bash
curl -X POST \
  https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload \
  -F "file=@/path/to/image.jpg" \
  -F "upload_preset=food_ai_unsigned"
```

---

## Bước 6: Cài Dependencies

### Sửa `pubspec.yaml`:

```yaml
name: food_ai_app
description: AI Food Recognition App
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0

  # Image
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1

  # HTTP
  dio: ^5.4.3+1

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # UI
  go_router: ^14.1.4
  fl_chart: ^0.68.0
  lottie: ^3.1.2
  shimmer: ^3.0.0

  # Utils
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  logger: ^2.3.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  mocktail: ^1.0.3
```

```bash
flutter pub get
```

---

## Bước 7: Tạo file cấu hình môi trường

Tạo `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Cloudinary
  static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'food_ai_unsigned';
  static const String cloudinaryBaseUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  // AI API
  static const String aiApiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator trỏ về localhost
  // static const String aiApiBaseUrl = 'https://your-api.com'; // Production

  // App
  static const String appName = 'Food AI';
  static const int defaultCalorieGoal = 2000;
}
```

> ⚠️ **QUAN TRỌNG:** Không commit file này nếu có API key thật. Thêm vào `.gitignore`.

---

## Bước 8: Khởi tạo Firebase trong main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart'; // auto-generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## Bước 9: Chạy App

```bash
# Chạy trên emulator
flutter run

# Chạy trên device thật (cắm USB, bật Developer Options)
flutter run -d YOUR_DEVICE_ID

# Build APK debug để cài trên điện thoại
flutter build apk --debug
# File APK: build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🐛 Fix lỗi phổ biến

### Lỗi 1: Gradle build failed

```
FAILURE: Build failed with an exception.
```

**Fix:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Lỗi 2: Google services plugin missing

```
Plugin with id 'com.google.gms.google-services' not found
```

**Fix:** Kiểm tra lại Bước 4.3 — phải sửa **cả 2 file** `build.gradle`.

### Lỗi 3: Firebase Auth not initialized

```
No Firebase App '[DEFAULT]' has been created
```

**Fix:** Đảm bảo `await Firebase.initializeApp()` chạy trước `runApp()`.

### Lỗi 4: Emulator không kết nối được API localhost

Dùng `10.0.2.2` thay vì `localhost` trong emulator Android.

### Lỗi 5: image_picker crash Android

Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## ✅ Checklist Setup

- [ ] Flutter SDK cài xong, `flutter doctor` không có lỗi đỏ
- [ ] Android Studio + Emulator chạy được
- [ ] Firebase project tạo xong
- [ ] `google-services.json` đã copy vào đúng thư mục
- [ ] Authentication và Firestore đã enable
- [ ] Cloudinary account tạo xong, có upload preset unsigned
- [ ] `flutter pub get` chạy thành công
- [ ] App khởi động không lỗi
