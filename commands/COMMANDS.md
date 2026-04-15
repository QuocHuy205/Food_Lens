# ⚡ COMMANDS — Template thêm Feature mới

> Copy template này mỗi khi thêm feature mới. Thứ tự: Model → Repository → UseCase → ViewModel → UI

---

## Thứ tự tạo file (BẮT BUỘC)

```
1. domain/entities/[feature]_entity.dart
2. data/models/[feature]_model.dart
3. domain/repositories/[feature]_repository.dart  (abstract)
4. data/datasources/[feature]_datasource.dart
5. data/repositories/[feature]_repository_impl.dart
6. domain/usecases/[action]_usecase.dart
7. presentation/providers/[feature]_provider.dart  (ViewModel)
8. presentation/screens/[feature]_screen.dart
```

---

## Template: Entity

```dart
// features/[feature]/domain/entities/[feature]_entity.dart
class [Feature]Entity {
  final String id;
  // ... fields

  const [Feature]Entity({
    required this.id,
    // ...
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is [Feature]Entity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

---

## Template: Model (Data Layer)

```dart
// features/[feature]/data/models/[feature]_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/[feature]_entity.dart';

class [Feature]Model {
  final String id;
  // ... fields

  const [Feature]Model({required this.id});

  factory [Feature]Model.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return [Feature]Model(
      id: doc.id,
      // map fields...
    );
  }

  Map<String, dynamic> toFirestore() => {
    // map to Firestore...
  };

  [Feature]Entity toEntity() => [Feature]Entity(
    id: id,
    // map fields...
  );
}
```

---

## Template: Repository Abstract

```dart
// features/[feature]/domain/repositories/[feature]_repository.dart
import 'package:dartz/dartz.dart'; // hoặc tự viết Either
import '../../../../core/errors/failure.dart';
import '../entities/[feature]_entity.dart';

abstract class [Feature]Repository {
  Future<Either<Failure, [Feature]Entity>> get[Feature](String id);
  Future<Either<Failure, List<[Feature]Entity>>> getAll[Feature]s(String userId);
  Future<Either<Failure, void>> save[Feature]([Feature]Entity entity);
  Future<Either<Failure, void>> delete[Feature](String id);
}
```

---

## Template: Repository Implementation

```dart
// features/[feature]/data/repositories/[feature]_repository_impl.dart
class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]DataSource _dataSource;

  [Feature]RepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, [Feature]Entity>> get[Feature](String id) async {
    try {
      final model = await _dataSource.get[Feature](id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // implement other methods...
}
```

---

## Template: UseCase

```dart
// features/[feature]/domain/usecases/[action]_usecase.dart
class [Action][Feature]UseCase {
  final [Feature]Repository _repository;

  [Action][Feature]UseCase(this._repository);

  Future<Either<Failure, ResultType>> call(ParamType param) {
    return _repository.[action](param);
  }
}
```

---

## Template: ViewModel (Riverpod)

```dart
// features/[feature]/presentation/providers/[feature]_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '[feature]_provider.g.dart';

// State
@freezed  // hoặc class thường
class [Feature]State with _$[Feature]State {
  const factory [Feature]State.initial() = [Feature]Initial;
  const factory [Feature]State.loading() = [Feature]Loading;
  const factory [Feature]State.success([Feature]Entity data) = [Feature]Success;
  const factory [Feature]State.error(String message) = [Feature]Error;
}

// ViewModel
@riverpod
class [Feature]ViewModel extends _$[Feature]ViewModel {
  @override
  [Feature]State build() => const [Feature]State.initial();

  Future<void> load(String id) async {
    state = const [Feature]State.loading();
    final result = await ref.read(get[Feature]UseCaseProvider).call(id);
    state = result.fold(
      (failure) => [Feature]State.error(failure.message),
      (data) => [Feature]State.success(data),
    );
  }
}
```

---

## Template: Screen (UI)

```dart
// features/[feature]/presentation/screens/[feature]_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/[feature]_provider.dart';

class [Feature]Screen extends ConsumerWidget {
  const [Feature]Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch([feature]ViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('[Feature]')),
      body: switch (state) {
        [Feature]Loading() => const Center(child: CircularProgressIndicator()),
        [Feature]Error(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message),
                ElevatedButton(
                  onPressed: () => ref.read([feature]ViewModelProvider.notifier).load('id'),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        [Feature]Success(:final data) => _buildContent(data),
        _ => const SizedBox(),
      },
    );
  }

  Widget _buildContent([Feature]Entity data) {
    return ListView(
      children: [
        // Build UI from data
      ],
    );
  }
}
```

---

## Ví dụ thực tế: Feature "Nutrition Stats"

```bash
# Tạo các file
touch lib/features/nutrition/domain/entities/daily_log_entity.dart
touch lib/features/nutrition/data/models/daily_log_model.dart
touch lib/features/nutrition/domain/repositories/nutrition_repository.dart
touch lib/features/nutrition/data/datasources/nutrition_datasource.dart
touch lib/features/nutrition/data/repositories/nutrition_repository_impl.dart
touch lib/features/nutrition/domain/usecases/get_weekly_logs_usecase.dart
touch lib/features/nutrition/presentation/providers/nutrition_provider.dart
touch lib/features/nutrition/presentation/screens/stats_screen.dart
```

Sau đó điền code theo template ở trên, thay `[Feature]` bằng `Nutrition` và `[feature]` bằng `nutrition`.
