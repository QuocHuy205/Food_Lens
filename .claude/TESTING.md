# 🧪 TESTING — Hướng dẫn viết test

---

## Cấu trúc test

```
test/
├── unit/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_repository_test.dart
│   │   │   └── login_usecase_test.dart
│   │   ├── scan/
│   │   │   ├── scan_repository_test.dart
│   │   │   └── analyze_food_usecase_test.dart
│   │   └── nutrition/
│   │       └── daily_log_repository_test.dart
│   └── core/
│       └── tdee_calculator_test.dart
├── widget/
│   └── scan_result_card_test.dart
└── mocks/
    └── mock_repositories.dart
```

---

## Mock với mocktail

```dart
// test/mocks/mock_repositories.dart
import 'package:mocktail/mocktail.dart';
import 'package:food_ai_app/features/scan/domain/repositories/scan_repository.dart';

class MockScanRepository extends Mock implements ScanRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
```

---

## Ví dụ test UseCase

```dart
// test/unit/features/scan/analyze_food_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late AnalyzeFoodUseCase useCase;
  late MockScanRepository mockRepo;

  setUp(() {
    mockRepo = MockScanRepository();
    useCase = AnalyzeFoodUseCase(mockRepo);
  });

  group('AnalyzeFoodUseCase', () {
    const testImageUrl = 'https://cloudinary.com/test.jpg';
    final testResult = ScanResult(
      foodName: 'Phở bò',
      foodNameVi: 'Phở bò',
      caloriesEstimated: 350.0,
      confidence: 0.92,
    );

    test('trả về ScanResult khi thành công', () async {
      // Arrange
      when(() => mockRepo.analyzeFoodImage(testImageUrl))
          .thenAnswer((_) async => Right(testResult));

      // Act
      final result = await useCase(testImageUrl);

      // Assert
      expect(result, Right(testResult));
      verify(() => mockRepo.analyzeFoodImage(testImageUrl)).called(1);
    });

    test('trả về NetworkFailure khi mạng lỗi', () async {
      // Arrange
      when(() => mockRepo.analyzeFoodImage(any()))
          .thenAnswer((_) async => const Left(NetworkFailure('No internet')));

      // Act
      final result = await useCase(testImageUrl);

      // Assert
      expect(result, const Left(NetworkFailure('No internet')));
    });
  });
}
```

---

## Ví dụ test Repository với mock Firestore

```dart
// test/unit/features/scan/scan_repository_test.dart
void main() {
  late ScanRepositoryImpl repository;
  late MockAiRemoteDataSource mockAiSource;
  late MockFirestoreDataSource mockFirestore;

  setUp(() {
    mockAiSource = MockAiRemoteDataSource();
    mockFirestore = MockFirestoreDataSource();
    repository = ScanRepositoryImpl(mockAiSource, mockFirestore);
  });

  test('saveScanHistory lưu thành công', () async {
    final scan = ScanHistory(
      id: 'test-id',
      userId: 'user-123',
      foodName: 'Phở bò',
      totalCalories: 350,
      createdAt: DateTime.now(),
    );

    when(() => mockFirestore.saveScan(any()))
        .thenAnswer((_) async => {});

    final result = await repository.saveScanHistory(scan);

    expect(result.isRight(), true);
  });
}
```

---

## Chạy test

```bash
# Chạy tất cả test
flutter test

# Chạy 1 file cụ thể
flutter test test/unit/features/scan/analyze_food_usecase_test.dart

# Xem coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Coverage mục tiêu

| Layer | Coverage mục tiêu |
|-------|--------------------|
| UseCase | ≥ 80% |
| Repository | ≥ 70% |
| ViewModel | ≥ 60% |
| Core Utils | ≥ 80% |
| **Tổng** | **≥ 60%** |
