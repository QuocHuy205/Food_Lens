import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/daily_log.dart';
import '../repositories/nutrition_repository.dart';

class GetDailyLogUseCase {
  final NutritionRepository repository;

  GetDailyLogUseCase({required this.repository});

  Future<Either<Failure, DailyLog>> call(String userId, DateTime date) async {
    return await repository.getDailyLog(userId, date);
  }
}
