import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/scan_result.dart';
import '../repositories/scan_repository.dart';

class AnalyzeFoodUseCase {
  final ScanRepository repository;

  AnalyzeFoodUseCase({required this.repository});

  Future<Either<Failure, ScanResult>> call(File imageFile) async {
    return await repository.analyzeFood(imageFile);
  }
}
