import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/daily_log.dart';

abstract class NutritionRepository {
  Future<Either<Failure, DailyLog>> getDailyLog(String userId, DateTime date);
  Future<Either<Failure, void>> updateDailyLog(DailyLog log);
  Future<Either<Failure, List<DailyLog>>> getWeeklySummary(String userId);
}
