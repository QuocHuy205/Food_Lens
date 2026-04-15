import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_datasource.dart';
import '../models/daily_log_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionDatasource datasource;

  NutritionRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, DailyLog>> getDailyLog(
      String userId, DateTime date) async {
    try {
      final data = await datasource.getDailyLog(userId, date);
      final log = DailyLogModel.fromJson(data);
      return Right(log);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDailyLog(DailyLog log) async {
    try {
      await datasource.updateDailyLog((log as DailyLogModel).toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyLog>>> getWeeklySummary(
      String userId) async {
    try {
      // TODO: Implement weekly summary fetch
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
