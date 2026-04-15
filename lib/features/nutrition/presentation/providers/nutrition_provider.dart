import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/nutrition_viewmodel.dart';

final nutritionViewModelProvider =
    StateNotifierProvider<NutritionViewModel, NutritionState>((ref) {
  // TODO: Inject dependencies when ready
  return NutritionViewModel();
});
