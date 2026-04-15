import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_history.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/cloudinary_datasource.dart';
import '../models/scan_result_model.dart';
import '../models/scan_history_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  final AiRemoteDatasource aiRemoteDatasource;
  final CloudinaryDatasource cloudinaryDatasource;

  ScanRepositoryImpl({
    required this.aiRemoteDatasource,
    required this.cloudinaryDatasource,
  });

  @override
  Future<Either<Failure, ScanResult>> analyzeFood(String imageUrl) async {
    try {
      final result = await aiRemoteDatasource.analyzeFood(imageUrl);
      final scanResult = ScanResultModel.fromJson(result);
      return Right(scanResult);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveScanHistory(ScanHistory history) async {
    try {
      // TODO: Save to Firestore
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ScanHistory>>> getScanHistory(
      String userId) async {
    try {
      // TODO: Fetch from Firestore
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
