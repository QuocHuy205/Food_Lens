import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/daily_log.dart';
import '../repositories/nutrition_repository.dart';

class GetWeeklySummaryUseCase {
  final NutritionRepository repository;

  GetWeeklySummaryUseCase({required this.repository});

  Future<Either<Failure, List<DailyLog>>> call(String userId) async {
    return await repository.getWeeklySummary(userId);
  }
}
