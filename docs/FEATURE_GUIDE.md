# 📚 FEATURE GUIDE — Hướng dẫn code từng Feature

---

## Feature: Scan Food (Ví dụ đầy đủ nhất)

### Bước 1: Entity

```dart
// features/scan/domain/entities/scan_result.dart
class ScanResult {
  final String foodName;
  final String foodNameVi;
  final double caloriesEstimated;
  final double confidence;
  final double portionGrams;
  final NutritionInfo nutrition;
  final List<PredictionItem> topPredictions;
  final bool isFallback;

  const ScanResult({
    required this.foodName,
    required this.foodNameVi,
    required this.caloriesEstimated,
    required this.confidence,
    this.portionGrams = 100.0,
    required this.nutrition,
    this.topPredictions = const [],
    this.isFallback = false,
  });

  String get confidenceLabel {
    if (confidence >= 0.9) return 'Rất chắc chắn';
    if (confidence >= 0.7) return 'Khá chắc chắn';
    if (confidence >= 0.5) return 'Có thể';
    return 'Không chắc';
  }
}

class NutritionInfo {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;

  const NutritionInfo({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
  });
}
```

### Bước 2: Model

```dart
// features/scan/data/models/scan_result_model.dart
class ScanResultModel {
  final String foodName;
  final String foodNameVi;
  final double confidence;
  final double caloriesEstimated;
  final double portionGrams;
  final Map<String, dynamic> nutrition;
  final List<Map<String, dynamic>> topPredictions;

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      foodName: json['food_name'] as String,
      foodNameVi: json['food_name_vi'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      caloriesEstimated: (json['calories_estimated'] as num).toDouble(),
      portionGrams: (json['portion_grams'] as num).toDouble(),
      nutrition: json['nutrition'] as Map<String, dynamic>,
      topPredictions: List<Map<String, dynamic>>.from(json['top_predictions'] ?? []),
    );
  }

  ScanResult toDomain() => ScanResult(
    foodName: foodName,
    foodNameVi: foodNameVi,
    confidence: confidence,
    caloriesEstimated: caloriesEstimated,
    portionGrams: portionGrams,
    nutrition: NutritionInfo(
      proteinG: (nutrition['protein_g'] as num).toDouble(),
      carbsG: (nutrition['carbs_g'] as num).toDouble(),
      fatG: (nutrition['fat_g'] as num).toDouble(),
      fiberG: (nutrition['fiber_g'] as num).toDouble(),
    ),
    topPredictions: topPredictions
        .map((p) => PredictionItem(
              name: p['name'] as String,
              confidence: (p['confidence'] as num).toDouble(),
            ))
        .toList(),
  );
}
```

### Bước 3: ViewModel State

```dart
// features/scan/presentation/providers/scan_provider.dart
class ScanState {
  final File? selectedImage;
  final bool isLoading;
  final String? errorMessage;
  final ScanResult? result;

  const ScanState({
    this.selectedImage,
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  ScanState copyWith({
    File? selectedImage,
    bool? isLoading,
    String? errorMessage,
    ScanResult? result,
  }) => ScanState(
    selectedImage: selectedImage ?? this.selectedImage,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
    result: result ?? this.result,
  );
}

@riverpod
class ScanViewModel extends _$ScanViewModel {
  @override
  ScanState build() => const ScanState();

  Future<void> pickFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      state = state.copyWith(selectedImage: File(image.path), result: null);
    }
  }

  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      state = state.copyWith(selectedImage: File(image.path), result: null);
    }
  }

  Future<void> analyzeImage() async {
    if (state.selectedImage == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    // 1. Upload
    final uploadResult = await ref.read(uploadImageUseCaseProvider)
        .call(state.selectedImage!);

    if (uploadResult.isLeft()) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: uploadResult.fold((f) => f.message, (_) => ''),
      );
      return;
    }

    final imageUrl = uploadResult.getOrElse(() => '');

    // 2. Analyze
    final analyzeResult = await ref.read(analyzeFoodUseCaseProvider).call(imageUrl);

    analyzeResult.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (result) => state = state.copyWith(isLoading: false, result: result),
    );
  }
}
```

### Bước 4: Scan Result Screen

```dart
// features/scan/presentation/screens/scan_result_screen.dart
class ScanResultScreen extends ConsumerWidget {
  final ScanResult result;
  const ScanResultScreen({required this.result, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả nhận diện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveScan(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food name + confidence
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(result.foodNameVi,
                              style: AppTextStyles.headline2),
                          Text(result.foodName,
                              style: AppTextStyles.caption),
                          const SizedBox(height: 8),
                          _ConfidenceBadge(confidence: result.confidence),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${result.caloriesEstimated.toStringAsFixed(0)}',
                          style: AppTextStyles.calorieNumber,
                        ),
                        const Text('kcal', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nutrition breakdown
            Text('Thành phần dinh dưỡng', style: AppTextStyles.title),
            const SizedBox(height: 8),
            _NutritionGrid(nutrition: result.nutrition),

            const SizedBox(height: 16),

            // Meal type selector
            Text('Bữa ăn', style: AppTextStyles.title),
            const SizedBox(height: 8),
            _MealTypeSelector(),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Lưu vào nhật ký'),
                onPressed: () => _saveScan(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveScan(BuildContext context, WidgetRef ref) async {
    final mealType = ref.read(selectedMealTypeProvider);
    await ref.read(saveScanHistoryUseCaseProvider).call(
      SaveScanParams(result: result, mealType: mealType),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu vào nhật ký!')),
      );
      context.go('/home');
    }
  }
}
```

---

## Feature: TDEE Calculator

```dart
// core/utils/tdee_calculator.dart
class TdeeCalculator {
  /// Tính BMR theo công thức Mifflin-St Jeor
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (gender == 'male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  /// Tính TDEE = BMR × activity factor
  static double calculateTdee({
    required double bmr,
    required String activityLevel,
  }) {
    final factors = {
      'sedentary': 1.2,    // Ít/không vận động
      'light': 1.375,      // Nhẹ nhàng 1-3 ngày/tuần
      'moderate': 1.55,    // Vừa phải 3-5 ngày/tuần
      'active': 1.725,     // Nhiều 6-7 ngày/tuần
      'very_active': 1.9,  // Rất nhiều hoặc 2 lần/ngày
    };
    return bmr * (factors[activityLevel] ?? 1.55);
  }

  /// Tính mục tiêu calo theo goal
  static double calculateGoalCalories({
    required double tdee,
    required String goal,
  }) => switch (goal) {
    'lose' => tdee - 500,     // Giảm 0.5kg/tuần
    'gain' => tdee + 500,     // Tăng 0.5kg/tuần
    _ => tdee,                // Giữ nguyên
  };
}
```

---

## Feature: Stats Screen

```dart
// features/nutrition/presentation/screens/stats_screen.dart
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyData = ref.watch(weeklyNutritionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: weeklyData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (logs) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Bar chart 7 ngày
              _WeeklyCalorieChart(logs: logs),
              const SizedBox(height: 24),
              // Summary cards
              _NutritionSummaryCards(logs: logs),
            ],
          ),
        ),
      ),
    );
  }
}

// Chart dùng fl_chart
class _WeeklyCalorieChart extends StatelessWidget {
  final List<DailyLog> logs;
  const _WeeklyCalorieChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calo 7 ngày qua', style: AppTextStyles.title),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: logs.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.totalCalories,
                          color: entry.value.totalCalories > entry.value.calorieGoal
                              ? AppColors.error
                              : AppColors.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                          return Text(days[value.toInt() % 7], style: AppTextStyles.caption);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
