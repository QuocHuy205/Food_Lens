import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/scan_result.dart';
import '../entities/scan_history.dart';

abstract class ScanRepository {
  Future<Either<Failure, ScanResult>> analyzeFood(String imageUrl);
  Future<Either<Failure, void>> saveScanHistory(ScanHistory history);
  Future<Either<Failure, List<ScanHistory>>> getScanHistory(String userId);
}
