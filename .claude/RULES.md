# 📐 RULES — Quy tắc kiến trúc bắt buộc

> AI agent đọc file này trước khi viết bất kỳ dòng code nào.

---

## Kiến trúc: Clean Architecture + MVVM

```
lib/
├── core/           ← Dùng chung toàn app (không feature-specific)
├── features/       ← Mỗi tính năng là 1 thư mục riêng
│   └── scan/
│       ├── data/           ← Data layer
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/         ← Business logic layer
│       │   ├── entities/
│       │   ├── repositories/ (abstract)
│       │   └── usecases/
│       └── presentation/   ← UI layer
│           ├── providers/
│           ├── viewmodels/
│           └── screens/
```

---

## Luồng dữ liệu (BẮT BUỘC)

```
UI (Widget)
  ↓ gọi
ViewModel (StateNotifier)
  ↓ gọi
UseCase (business logic)
  ↓ gọi
Repository (abstract interface)
  ↓ implement bởi
RepositoryImpl
  ↓ gọi
DataSource (Firestore / API / Local)
```

### ❌ KHÔNG được làm:
```dart
// Widget gọi thẳng Firestore — SAI
class ScanScreen extends StatelessWidget {
  Future<void> _save() async {
    await FirebaseFirestore.instance.collection('scans').add({...}); // ❌
  }
}
```

### ✅ PHẢI làm:
```dart
// Widget chỉ gọi ViewModel
class ScanScreen extends ConsumerWidget {
  void _save(WidgetRef ref) {
    ref.read(scanViewModelProvider.notifier).saveScan(result); // ✅
  }
}
```

---

## Repository Pattern

### Abstract (domain layer):
```dart
// features/scan/domain/repositories/scan_repository.dart
abstract class ScanRepository {
  Future<Either<Failure, ScanResult>> analyzeFoodImage(String imageUrl);
  Future<Either<Failure, void>> saveScanHistory(ScanHistory scan);
  Future<Either<Failure, List<ScanHistory>>> getScanHistory(String userId);
}
```

### Implementation (data layer):
```dart
// features/scan/data/repositories/scan_repository_impl.dart
class ScanRepositoryImpl implements ScanRepository {
  final AiRemoteDataSource _aiDataSource;
  final FirestoreDataSource _firestoreDataSource;

  ScanRepositoryImpl(this._aiDataSource, this._firestoreDataSource);

  @override
  Future<Either<Failure, ScanResult>> analyzeFoodImage(String imageUrl) async {
    try {
      final result = await _aiDataSource.analyze(imageUrl);
      return Right(result.toDomain());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

---

## Error Handling

Dùng `Either` từ package `fpdart` hoặc tự viết:

```dart
// core/errors/failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
```

---

## UseCase Pattern

```dart
// features/scan/domain/usecases/analyze_food_usecase.dart
class AnalyzeFoodUseCase {
  final ScanRepository _repository;

  AnalyzeFoodUseCase(this._repository);

  Future<Either<Failure, ScanResult>> call(String imageUrl) {
    return _repository.analyzeFoodImage(imageUrl);
  }
}
```

---

## ViewModel với Riverpod

```dart
// features/scan/presentation/providers/scan_provider.dart
@riverpod
class ScanViewModel extends _$ScanViewModel {
  @override
  ScanState build() => const ScanState.initial();

  Future<void> analyzeImage(File imageFile) async {
    state = const ScanState.loading();

    // 1. Upload ảnh
    final uploadResult = await ref.read(uploadImageUseCaseProvider).call(imageFile);
    if (uploadResult.isLeft()) {
      state = ScanState.error(uploadResult.fold((f) => f.message, (_) => ''));
      return;
    }
    final imageUrl = uploadResult.getOrElse(() => '');

    // 2. Gọi AI
    final analyzeResult = await ref.read(analyzeFoodUseCaseProvider).call(imageUrl);
    analyzeResult.fold(
      (failure) => state = ScanState.error(failure.message),
      (result) => state = ScanState.success(result),
    );
  }
}
```

---

## Naming Convention

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| File | snake_case | `scan_screen.dart` |
| Class | PascalCase | `ScanScreen` |
| Variable | camelCase | `imageUrl` |
| Constant | camelCase | `defaultCalorieGoal` |
| Provider | camelCase + Provider | `scanViewModelProvider` |

---

## Quy tắc tuyệt đối

1. **Widget không chứa logic** — chỉ gọi ViewModel
2. **Repository không biết UI tồn tại**
3. **UseCase = 1 hàm duy nhất** — không viết 5 hàm trong 1 UseCase
4. **Mỗi file 1 class** (trừ model + extension nhỏ)
5. **Không dùng setState trong màn hình chính** — dùng Riverpod
