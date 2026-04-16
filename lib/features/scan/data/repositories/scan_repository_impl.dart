import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_history.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/cloudinary_datasource.dart';
import '../datasources/firestore_datasource.dart';
import '../models/scan_result_model.dart';
import '../models/scan_history_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  final AiRemoteDatasource aiRemoteDatasource;
  final CloudinaryDatasource cloudinaryDatasource;
  final FirestoreDatasource firestoreDatasource;

  ScanRepositoryImpl({
    required this.aiRemoteDatasource,
    required this.cloudinaryDatasource,
    required this.firestoreDatasource,
  });

  @override
  Future<Either<Failure, ScanResult>> analyzeFood(String imageUrl) async {
    try {
      final result = await aiRemoteDatasource.analyzeFood(imageUrl);
      final scanResult = ScanResultModel.fromJson(result);
      return Right(scanResult);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Lỗi phân tích ảnh: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveScanHistory(ScanHistory history) async {
    try {
      final historyModel = ScanHistoryModel(
        id: history.id,
        userId: history.userId,
        foodName: history.foodName,
        calories: history.calories,
        imageUrl: history.imageUrl,
        createdAt: history.createdAt,
        quantity: history.quantity,
      );

      await firestoreDatasource.saveScanHistory(
        history.userId,
        historyModel,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi lưu lịch sử: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanHistory>>> getScanHistory(
      String userId) async {
    try {
      final histories = await firestoreDatasource.getScanHistory(userId);
      return Right(histories);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi lấy lịch sử: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanHistory>>> getScanHistoryByDate(
    String userId,
    String date,
  ) async {
    try {
      final histories = await firestoreDatasource.getScanHistoryByDate(
        userId,
        date,
      );
      return Right(histories);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi lấy lịch sử theo ngày: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteScanHistory(
    String userId,
    String scanId,
  ) async {
    try {
      await firestoreDatasource.deleteScanHistory(userId, scanId);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi xoá lịch sử: ${e.toString()}',
        ),
      );
    }
  }
}

/// Database failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message);
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}
