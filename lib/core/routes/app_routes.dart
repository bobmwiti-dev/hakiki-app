/// App Routes
///
/// Centralized route definitions for the Hakiki app.
/// Use these constants for navigation throughout the app.
library;

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingFeatures = '/onboarding/features';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneAuth = '/phone-auth';
  static const String home = '/home';
  static const String vendorRegistration = '/vendor/registration';
  static const String qrScanner = '/qr/scanner';
  static const String productVerification = '/qr/verification';
  static const String fraudReport = '/fraud/report';
  static const String reportHistory = '/fraud/history';
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
  static const String profile = '/profile';
  static const String vendorDashboard = '/vendor/dashboard';
  static const String addProduct = '/vendor/add-product';

  // Private constructor to prevent instantiation
  AppRoutes._();
}
