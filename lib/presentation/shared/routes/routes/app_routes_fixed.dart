import 'package:flutter/material.dart';

class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneAuth = '/phone-auth';
  static const String authWrapper = '/auth-wrapper';

  // Main app routes
  static const String home = '/home';
  static const String qrScanner = '/qr-scanner';
  static const String productVerification = '/product-verification';
  static const String vendorRegistration = '/vendor-registration';
  static const String fraudReport = '/fraud-report';
  static const String adminDashboard = '/admin-dashboard';
  static const String profile = '/profile';

  // Route map - screen implementations need to be created
  static Map<String, WidgetBuilder> get routes => {
    // Note: All screen classes need to be implemented
    // Currently only route constants are defined
  };
}
