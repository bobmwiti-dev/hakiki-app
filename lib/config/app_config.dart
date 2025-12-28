/// App Configuration
/// 
/// Environment-specific configuration settings.
/// Adjust these values based on your deployment environment.
library;

class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.hakiki.app',
  );

  // Firebase Configuration
  static const bool enableFirebaseAnalytics = true;
  static const bool enableFirebaseCrashlytics = true;

  // Feature Flags
  static const bool enableQRScanner = true;
  static const bool enableBarcodeScanner = true;
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = false;

  // App Settings
  static const int maxFileUploadSizeMB = 10;
  static const int maxImageUploadSizeMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Settings
  static const int cacheExpirationMinutes = 30;
  static const int maxCacheSizeMB = 50;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minProductIdLength = 3;
  static const int maxProductIdLength = 50;

  // Trust Score
  static const int defaultTrustScore = 0;
  static const int maxTrustScore = 100;
  static const int minTrustScore = 0;

  // Development/Debug Settings
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // Logging
  static bool get enableLogging => isDevelopment || isStaging;
  static bool get enableVerboseLogging => isDevelopment;
}

