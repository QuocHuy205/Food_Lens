# 🏗️ ARCHITECTURE — Clean Architecture + MVVM

---

## Tổng quan kiến trúc

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                  │
│  Screens / Widgets  ←→  ViewModels (StateNotifier)  │
│              (Flutter Riverpod)                      │
└──────────────────┬──────────────────────────────────┘
                   │ calls UseCase
┌──────────────────▼──────────────────────────────────┐
│                   DOMAIN LAYER                       │
│      UseCases  ←→  Entities  ←→  Repository (abs)   │
│          (Pure Dart, không import Flutter)          │
└──────────────────┬──────────────────────────────────┘
                   │ implemented by
┌──────────────────▼──────────────────────────────────┐
│                    DATA LAYER                        │
│   Repository Impl  ←→  Models  ←→  DataSources      │
│     (Firestore, AI API, Cloudinary)                 │
└─────────────────────────────────────────────────────┘
```

---

## Tại sao dùng Clean Architecture?

Với sinh viên năm 3, Clean Architecture có vẻ phức tạp nhưng có lý do:

1. **Dễ test** — Domain layer không phụ thuộc Flutter, test bằng pure Dart
2. **Dễ thay đổi** — Muốn đổi từ Firestore sang SQLite? Chỉ sửa DataLayer
3. **Dễ đọc** — Mỗi file có 1 mục đích rõ ràng
4. **Điểm cao hơn** — Giảng viên thích kiến trúc tốt

---

## Dependency Injection với Riverpod

```dart
// Cách wire các dependency:

// 1. DataSource
@riverpod
AiRemoteDataSource aiDataSource(AiDataSourceRef ref) {
  return AiRemoteDataSource(ref.watch(dioProvider));
}

// 2. Repository
@riverpod
ScanRepository scanRepository(ScanRepositoryRef ref) {
  return ScanRepositoryImpl(
    ref.watch(aiDataSourceProvider),
    ref.watch(firestoreDataSourceProvider),
    ref.watch(cloudinaryDataSourceProvider),
  );
}

// 3. UseCase
@riverpod
AnalyzeFoodUseCase analyzeFoodUseCase(AnalyzeFoodUseCaseRef ref) {
  return AnalyzeFoodUseCase(ref.watch(scanRepositoryProvider));
}

// 4. ViewModel
@riverpod
class ScanViewModel extends _$ScanViewModel { ... }
```

---

## Data Flow — Ví dụ: Scan món ăn

```
ScanScreen.onTapAnalyze()
  │
  ▼
ScanViewModel.analyzeImage(imageFile)
  │
  ├──► UploadImageUseCase.call(imageFile)
  │         │
  │         ▼
  │    ScanRepository.uploadImage(imageFile)
  │         │
  │         ▼
  │    CloudinaryDataSource.upload(imageFile)
  │         │
  │         ▼ HTTP POST → Cloudinary API
  │         ◄ imageUrl: String
  │
  └──► AnalyzeFoodUseCase.call(imageUrl)
            │
            ▼
       ScanRepository.analyzeFoodImage(imageUrl)
            │
            ▼
       AiRemoteDataSource.analyzeFood(imageUrl)
            │
            ▼ HTTP POST → FastAPI /analyze
            ◄ ScanResultModel

ScanViewModel updates state → ScanScreen re-renders
```

---

## Xử lý lỗi toàn hệ thống

```dart
// 1. Exception (Data Layer) — lỗi kỹ thuật
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

// 2. Failure (Domain Layer) — lỗi business
abstract class Failure {
  final String message;
  const Failure(this.message);
}
class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class NotFoundFailure extends Failure { ... }

// 3. State (Presentation Layer) — hiển thị lỗi
ScanState.error(message)  // ViewModel state
→ UI hiển thị SnackBar hoặc Error widget
```
