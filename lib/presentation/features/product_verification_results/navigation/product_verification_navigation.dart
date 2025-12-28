import 'package:flutter/material.dart';
import '../../../shared/routes/routes/app_routes.dart';
import '../views/product_verification_results.dart';

class ProductVerificationNavigation {
  /// Navigate to product verification results screen
  static Future<void> navigateToResults(
    BuildContext context, {
    String? productId,
    Map<String, dynamic>? verificationData,
  }) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.productVerificationResults,
      arguments: {
        'productId': productId,
        'verificationData': verificationData,
      },
    );
  }

  /// Navigate to product verification results and replace current screen
  static Future<void> navigateToResultsReplacement(
    BuildContext context, {
    String? productId,
    Map<String, dynamic>? verificationData,
  }) async {
    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.productVerificationResults,
      arguments: {
        'productId': productId,
        'verificationData': verificationData,
      },
    );
  }

  /// Navigate to product verification results and clear stack
  static Future<void> navigateToResultsAndClearStack(
    BuildContext context, {
    String? productId,
    Map<String, dynamic>? verificationData,
  }) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.productVerificationResults,
      (route) => false,
      arguments: {
        'productId': productId,
        'verificationData': verificationData,
      },
    );
  }

  /// Show product verification results as modal bottom sheet
  static Future<void> showResultsModal(
    BuildContext context, {
    String? productId,
    Map<String, dynamic>? verificationData,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const ProductVerificationResults(),
      ),
    );
  }

  /// Navigate back from verification results
  static void navigateBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Navigate to home from verification results
  static Future<void> navigateToHome(BuildContext context) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  /// Navigate to QR scanner for new verification
  static Future<void> navigateToQRScanner(BuildContext context) async {
    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.qrScanner,
    );
  }
}
