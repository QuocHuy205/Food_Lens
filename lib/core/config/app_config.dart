import 'package:flutter_dotenv/flutter_dotenv.dart';

// API configurations and environment variables
class AppConfig {
  // Firebase
  static const String firebaseProjectId = 'food-ai-app-xxxxx';

  // Cloudinary — Load từ .env
  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'your-cloud-name';

  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'your-upload-preset';

  // AI API — Load từ .env hoặc default
  static String get aiApiBaseUrl =>
      dotenv.env['AI_SERVER_URL'] ?? 'http://10.0.2.2:8000'; // Android emulator

  static const String analyzeEndpoint = '/analyze';

  // App
  static const String appName = 'Food AI';
  static const String appVersion = '1.0.0';
}
