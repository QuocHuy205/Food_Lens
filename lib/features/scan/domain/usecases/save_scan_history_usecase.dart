import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/scan_history.dart';
import '../repositories/scan_repository.dart';

class SaveScanHistoryUseCase {
  final ScanRepository repository;

  SaveScanHistoryUseCase({required this.repository});

  Future<Either<Failure, void>> call(ScanHistory history) async {
    return await repository.saveScanHistory(history);
  }
}
