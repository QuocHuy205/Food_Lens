import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

abstract class CloudinaryDatasource {
  /// Upload ảnh lên Cloudinary
  /// Returns: imageUrl (secure_url từ Cloudinary)
  /// Throws: [ServerException] nếu upload fail
  Future<String> uploadImage(String filePath);
}

class CloudinaryDatasourceImpl implements CloudinaryDatasource {
  final Dio _dio;

  CloudinaryDatasourceImpl(this._dio);

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        throw ServerException('File không tồn tại: $filePath');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': AppConfig.cloudinaryUploadPreset,
      });

      const String cloudinaryUrl =
          'https://api.cloudinary.com/v1_1/{CLOUD_NAME}/image/upload';
      final url = cloudinaryUrl.replaceFirst(
        '{CLOUD_NAME}',
        AppConfig.cloudinaryCloudName,
      );

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final secureUrl = response.data['secure_url'] as String?;
        if (secureUrl != null) {
          return secureUrl;
        }
      }

      throw ServerException('Cloudinary upload failed: No URL returned');
    } on DioException catch (e) {
      throw ServerException(
        'Network error: ${e.message ?? 'Unknown'}',
      );
    } catch (e) {
      throw ServerException('Upload error: $e');
    }
  }
}

/// Exception khi upload server không respond
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
