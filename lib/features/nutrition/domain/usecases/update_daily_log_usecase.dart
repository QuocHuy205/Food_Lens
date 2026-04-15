import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/daily_log.dart';
import '../repositories/nutrition_repository.dart';

class UpdateDailyLogUseCase {
  final NutritionRepository repository;

  UpdateDailyLogUseCase({required this.repository});

  Future<Either<Failure, void>> call(DailyLog log) async {
    return await repository.updateDailyLog(log);
  }
}
