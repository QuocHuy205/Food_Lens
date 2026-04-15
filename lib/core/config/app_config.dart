// API configurations and environment variables
class AppConfig {
  // Firebase
  static const String firebaseProjectId = 'food-ai-app-xxxxx';

  // Cloudinary
  static const String cloudinaryCloudName = 'your-cloud-name';
  static const String cloudinaryUploadPreset = 'your-upload-preset';

  // AI API
  static const String aiApiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String analyzeEndpoint = '/analyze';

  // App
  static const String appName = 'Food AI';
  static const String appVersion = '1.0.0';
}
