// Application-wide constants (NON-SECRETS ONLY)
// For secrets (API keys, credentials), use .env file via flutter_dotenv
class AppConstants {
  // API Configuration
  static const String aiApiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String aiApiAnalyzeEndpoint = '/analyze';
  static const Duration aiApiTimeout = Duration(seconds: 30);

  // Firestore Collections (non-secret structure)
  static const String firebaseProjectId = 'food-ai-app';
  static const String firestoreUsersCollection = 'users';
  static const String firestoreScansCollection = 'scans';
  static const String firestoreDailyLogsCollection = 'daily_logs';
  static const String firestoreRecommendationsCollection = 'recommendations';

  // Cloudinary Configuration
  // NOTE: cloud_name, api_key, upload_preset are loaded from .env
  // Access via: dotenv.env['CLOUDINARY_CLOUD_NAME'] in code
  static const String cloudinaryImageTransformationWidth = '800';
  static const String cloudinaryImageQuality = 'auto';

  // App Metadata
  static const String appName = 'Food Lens AI';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int pageSize = 20;
  static const int initialPage = 1;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);

  // UI Duration
  static const Duration notificationDuration = Duration(seconds: 3);
}
