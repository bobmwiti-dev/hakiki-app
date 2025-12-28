class AppConstants {
  // App Info
  static const String appName = 'Hakiki';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Fraud Prevention for Digital Marketplaces';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String vendorsCollection = 'vendors';
  static const String productsCollection = 'products';
  static const String reportsCollection = 'reports';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String documentsPath = 'documents';
  static const String profileImagesPath = 'profile_images';
  static const String productImagesPath = 'product_images';
  static const String reportMediaPath = 'report_media';

  // User Roles
  static const String userRole = 'user';
  static const String vendorRole = 'vendor';
  static const String adminRole = 'admin';

  // Trust Score Ranges
  static const int minTrustScore = 0;
  static const int maxTrustScore = 100;
  static const int defaultTrustScore = 50;

  // Verification Status
  static const String pendingStatus = 'pending';
  static const String approvedStatus = 'approved';
  static const String rejectedStatus = 'rejected';
  static const String suspendedStatus = 'suspended';

  // Report Types
  static const String fraudReport = 'fraud';
  static const String fakeProductReport = 'fake_product';
  static const String scamReport = 'scam';
  static const String otherReport = 'other';

  // Notification Types
  static const String fraudAlert = 'fraud_alert';
  static const String vendorApproval = 'vendor_approval';
  static const String trustScoreUpdate = 'trust_score_update';
  static const String reportUpdate = 'report_update';

  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String userRoleKey = 'user_role';
  static const String lastSyncKey = 'last_sync';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.hakiki.com';
  static const String authEndpoint = '/auth';
  static const String verifyEndpoint = '/verify';
  static const String reportEndpoint = '/report';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImagesPerReport = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
}
