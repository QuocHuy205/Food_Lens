import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/scan_repository.dart';

class UploadImageUseCase {
  final ScanRepository repository;

  UploadImageUseCase({required this.repository});

  Future<Either<Failure, String>> call(String filePath) async {
    // TODO: Implement image upload to Cloudinary
    return Left(ServerFailure(message: 'Not implemented'));
  }
}
