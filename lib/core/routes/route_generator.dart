/// Route Generator
///
/// Generates routes for the Hakiki app.
/// Handles navigation with proper arguments.
library;

import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/onboarding/onboarding_welcome_screen.dart';
import '../../views/onboarding/onboarding_features_screen.dart';
import '../../views/vendor/vendor_registration_screen.dart';
import '../../views/vendor/add_product_screen.dart';
import '../../views/home/home_dashboard.dart';
import '../../views/qr/qr_scanner_screen.dart';
import '../../views/qr/product_verification_results_screen.dart';
import '../../views/fraud/fraud_report_screen.dart';
import '../../views/fraud/report_history_screen.dart';
import '../../views/vendor/vendor_dashboard_screen.dart';
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/vendor_review_screen.dart';
import '../../views/admin/report_review_screen.dart';
import '../../views/admin/user_management_screen.dart';
import '../../views/admin/admin_reports_screen.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/fraud_report_model.dart';
// Auth screens (from presentation folder)
import '../../presentation/features/auth/views/login_screen.dart';
import '../../presentation/features/auth/views/signup_screen.dart';
import '../../presentation/features/auth/views/phone_auth_screen.dart';
import '../../presentation/features/profile/views/profile_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboardingWelcome:
        return MaterialPageRoute(
          builder: (_) => const OnboardingWelcomeScreen(),
        );

      case AppRoutes.onboardingFeatures:
        return MaterialPageRoute(
          builder: (_) => const OnboardingFeaturesScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case AppRoutes.phoneAuth:
        return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.vendorRegistration:
        return MaterialPageRoute(
          builder: (_) => const VendorRegistrationScreen(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeDashboard());

      case AppRoutes.qrScanner:
        return MaterialPageRoute(builder: (_) => const QRScannerScreen());

      case AppRoutes.productVerification:
        if (args is Map) {
          if (args['type'] == 'product' && args['product'] is ProductModel) {
            return MaterialPageRoute(
              builder:
                  (_) => ProductVerificationResultsScreen(
                    data: args['product'],
                    type: 'product',
                  ),
            );
          } else if (args['type'] == 'vendor' &&
              args['vendor'] is VendorModel) {
            return MaterialPageRoute(
              builder:
                  (_) => ProductVerificationResultsScreen(
                    data: args['vendor'],
                    type: 'vendor',
                  ),
            );
          }
        }
        return MaterialPageRoute(
          builder:
              (_) => const ProductVerificationResultsScreen(
                data: null,
                type: 'product',
              ),
        );

      case AppRoutes.fraudReport:
        Map<String, String?>? reportArgs;
        if (args is Map) {
          reportArgs = {
            'productId': args['productId']?.toString(),
            'vendorId': args['vendorId']?.toString(),
          };
        }
        return MaterialPageRoute(
          builder:
              (_) => FraudReportScreen(
                productId: reportArgs?['productId'],
                vendorId: reportArgs?['vendorId'],
              ),
        );

      case AppRoutes.reportHistory:
        return MaterialPageRoute(builder: (_) => const ReportHistoryScreen());

      case AppRoutes.vendorDashboard:
        return MaterialPageRoute(builder: (_) => const VendorDashboardScreen());

      case AppRoutes.addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case AppRoutes.userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());

      case '/admin/vendors':
        return MaterialPageRoute(
          builder:
              (_) =>
                  const AdminDashboardScreen(), // TODO: Create vendor list screen
        );

      case '/admin/vendor/review':
        if (args is VendorModel) {
          return MaterialPageRoute(
            builder: (_) => VendorReviewScreen(vendor: args),
          );
        }
        return _errorRoute();

      case '/admin/reports':
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());

      case '/admin/report/review':
        if (args is FraudReportModel) {
          return MaterialPageRoute(
            builder: (_) => ReportReviewScreen(report: args),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Page not found')),
          ),
    );
  }
}
