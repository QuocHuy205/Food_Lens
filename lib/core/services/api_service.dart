import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:food_lens/core/config/app_config.dart';
import 'package:food_lens/core/services/auth_token_storage.dart';

class ApiService {
  late Dio _dio;

  // Thay đổi base URL phù hợp với máy của bạn
  // Nếu dùng máy ảo Android: 10.0.2.2
  // Nếu dùng máy thật: địa chỉ IP mạng nội bộ


  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "${AppConfig.aiApiBaseUrl}/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    // Thêm Interceptor để tự động đính kèm Token vào Header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token từ bộ nhớ đã lưu sau khi login thành công
          final token = await AuthTokenStorage.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              print('🔑 API Request: Gắn Token thành công');
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('❌ API Error: ${e.response?.statusCode} - ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Phương thức POST
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // Phương thức GET
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // Xử lý lỗi tập trung
  void _handleError(DioException e) {
    if (e.response != null) {
      // Lỗi từ phía Server trả về
      throw Exception(e.response?.data['detail'] ?? 'Lỗi hệ thống');
    } else {
      // Lỗi kết nối mạng
      throw Exception('Không thể kết nối tới Server. Vui lòng kiểm tra internet.');
    }
  }
}