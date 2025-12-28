import 'package:flutter/material.dart';

class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneAuth = '/phone-auth';
  static const String authWrapper = '/auth-wrapper';

  // Main navigation routes
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String verify = '/verify';
  static const String report = '/report';
  static const String profile = '/profile';

  // Onboarding routes
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingFeatures = '/onboarding/features';

  // Vendor routes
  static const String vendorRegistration = '/vendor/registration';
  static const String vendorProfile = '/vendor/profile';
  static const String vendorDashboard = '/vendor/dashboard';

  // QR/Verification routes
  static const String qrScanner = '/qr/scanner';
  static const String productVerification = '/qr/verification';
  static const String productDetails = '/product/details';

  // Fraud reporting routes
  static const String fraudReport = '/fraud/report';
  static const String fraudReportForm = '/fraud/report-form';
  static const String fraudReportScreen = '/fraud/report-screen';
  static const String reportHistory = '/fraud/history';

  // Product verification routes
  static const String productVerificationResults = '/product/verification-results';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReportReview = '/admin/reports';
  static const String adminVendorReview = '/admin/vendors';
  static const String adminUserManagement = '/admin/users';

  // Profile routes
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String about = '/profile/about';
  static const String privacyPolicy = '/profile/privacy';
  static const String termsOfService = '/profile/terms';

  // Utility routes
  static const String error = '/error';
  static const String noInternet = '/no-internet';

  // Route parameters
  static const String productIdParam = 'productId';
  static const String reportIdParam = 'reportId';
  static const String vendorIdParam = 'vendorId';
  static const String userIdParam = 'userId';

  // Route with parameters helpers
  static String productDetailsWithId(String productId) => '$productDetails?$productIdParam=$productId';
  static String reportDetailsWithId(String reportId) => '$reportHistory?$reportIdParam=$reportId';
  static String vendorProfileWithId(String vendorId) => '$vendorProfile?$vendorIdParam=$vendorId';

  // All routes list for easy navigation setup
  static const List<String> allRoutes = [
    splash,
    onboarding,
    login,
    signup,
    phoneAuth,
    authWrapper,
    mainNavigation,
    home,
    verify,
    report,
    profile,
    onboardingWelcome,
    onboardingFeatures,
    vendorRegistration,
    vendorProfile,
    vendorDashboard,
    qrScanner,
    productVerification,
    productDetails,
    fraudReport,
    fraudReportForm,
    fraudReportScreen,
    reportHistory,
    productVerificationResults,
    adminDashboard,
    adminReportReview,
    adminVendorReview,
    adminUserManagement,
    editProfile,
    settings,
    about,
    privacyPolicy,
    termsOfService,
    error,
    noInternet,
  ];

  // Protected routes that require authentication
  static const List<String> protectedRoutes = [
    mainNavigation,
    home,
    verify,
    report,
    profile,
    vendorRegistration,
    vendorProfile,
    vendorDashboard,
    qrScanner,
    productVerification,
    productDetails,
    fraudReport,
    fraudReportForm,
    reportHistory,
    editProfile,
    settings,
  ];

  // Admin only routes
  static const List<String> adminRoutes = [
    adminDashboard,
    adminReportReview,
    adminVendorReview,
    adminUserManagement,
  ];

  // Vendor only routes
  static const List<String> vendorRoutes = [
    vendorDashboard,
  ];

  // Public routes that don't require authentication
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    login,
    signup,
    phoneAuth,
    onboardingWelcome,
    onboardingFeatures,
    about,
    privacyPolicy,
    termsOfService,
    error,
    noInternet,
  ];

  // Route mappings - only include existing screens
  static Map<String, WidgetBuilder> routes = {
    // Note: Screen implementations need to be created
    // Currently only route constants are defined
  };

  // Legacy route names for backward compatibility
  static const String initial = splash;
  static const String splashScreen = splash;
  static const String homeDashboard = home;
  static const String qrCodeScanner = qrScanner;
}
