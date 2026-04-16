import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/scan_result.dart';
import '../entities/scan_history.dart';

abstract class ScanRepository {
  /// Phân tích ảnh từ URL
  Future<Either<Failure, ScanResult>> analyzeFood(String imageUrl);

  /// Lưu lịch sử scan
  Future<Either<Failure, void>> saveScanHistory(ScanHistory history);

  /// Lấy lịch sử scan của user
  Future<Either<Failure, List<ScanHistory>>> getScanHistory(String userId);

  /// Lấy lịch sử scan theo ngày
  Future<Either<Failure, List<ScanHistory>>> getScanHistoryByDate(
    String userId,
    String date,
  );

  /// Xoá scan history
  Future<Either<Failure, void>> deleteScanHistory(String userId, String scanId);
}
