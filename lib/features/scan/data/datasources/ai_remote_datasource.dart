import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

abstract class AiRemoteDatasource {
  /// Gửi image URL tới AI server, nhận kết quả phân tích
  /// Returns: Map với keys: food_name, calories_estimated, confidence, nutrition, etc.
  /// Throws: [ServerException] nếu API fail
  Future<Map<String, dynamic>> analyzeFood(String imageUrl);
}

class AiRemoteDatasourceImpl implements AiRemoteDatasource {
  final Dio _dio;

  AiRemoteDatasourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> analyzeFood(String imageUrl) async {
    try {
      final String url =
          '${AppConfig.aiApiBaseUrl}${AppConfig.analyzeEndpoint}';

      final response = await _dio.post(
        url,
        data: {
          'image_url': imageUrl,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw ServerException(
        'AI Server error: ${response.data['error'] ?? 'Unknown error'}',
      );
    } on DioException catch (e) {
      throw ServerException(
        'Network error: ${e.message ?? 'Unknown'}',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}

/// Exception khi AI server không respond
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
