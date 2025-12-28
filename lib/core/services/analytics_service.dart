import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({required FirebaseAnalytics analytics})
      : _analytics = analytics;

  // Set user properties
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }

  Future<void> setUserProperties({
    required String userId,
    required String role,
    String? trustScore,
  }) async {
    try {
      await _analytics.setUserProperty(name: 'user_role', value: role);
      if (trustScore != null) {
        await _analytics.setUserProperty(name: 'trust_score', value: trustScore);
      }
    } catch (e) {
      debugPrint('Failed to set user properties: $e');
    }
  }

  // Authentication events
  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Failed to log sign up: $e');
    }
  }

  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Failed to log login: $e');
    }
  }

  // Product verification events
  Future<void> logProductScan({
    required String scanType, // qr_code, barcode
    required bool successful,
    String? productId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'product_scan',
        parameters: {
          'scan_type': scanType,
          'successful': successful,
          if (productId != null) 'product_id': productId,
        },
      );
    } catch (e) {
      debugPrint('Failed to log product scan: $e');
    }
  }

  Future<void> logProductVerification({
    required String productId,
    required bool verified,
    required String trustLevel,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'product_verification',
        parameters: {
          'product_id': productId,
          'verified': verified,
          'trust_level': trustLevel,
        },
      );
    } catch (e) {
      debugPrint('Failed to log product verification: $e');
    }
  }

  // Fraud reporting events
  Future<void> logFraudReport({
    required String reportType,
    required String severity,
    String? productId,
    String? vendorId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'fraud_report',
        parameters: {
          'report_type': reportType,
          'severity': severity,
          if (productId != null) 'product_id': productId,
          if (vendorId != null) 'vendor_id': vendorId,
        },
      );
    } catch (e) {
      debugPrint('Failed to log fraud report: $e');
    }
  }

  // Vendor events
  Future<void> logVendorRegistration() async {
    try {
      await _analytics.logEvent(name: 'vendor_registration');
    } catch (e) {
      debugPrint('Failed to log vendor registration: $e');
    }
  }

  Future<void> logVendorApproval({
    required String vendorId,
    required bool approved,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'vendor_approval',
        parameters: {
          'vendor_id': vendorId,
          'approved': approved,
        },
      );
    } catch (e) {
      debugPrint('Failed to log vendor approval: $e');
    }
  }

  // User engagement events
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Failed to log screen view: $e');
    }
  }

  Future<void> logSearch(String searchTerm) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
    } catch (e) {
      debugPrint('Failed to log search: $e');
    }
  }

  Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: 'app_share',
      );
    } catch (e) {
      debugPrint('Failed to log share: $e');
    }
  }

  // Trust score events
  Future<void> logTrustScoreUpdate({
    required String userId,
    required int oldScore,
    required int newScore,
    required String reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'trust_score_update',
        parameters: {
          'user_id': userId,
          'old_score': oldScore,
          'new_score': newScore,
          'reason': reason,
        },
      );
    } catch (e) {
      debugPrint('Failed to log trust score update: $e');
    }
  }

  // Admin events
  Future<void> logAdminAction({
    required String action,
    required String targetType,
    required String targetId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'admin_action',
        parameters: {
          'action': action,
          'target_type': targetType,
          'target_id': targetId,
        },
      );
    } catch (e) {
      debugPrint('Failed to log admin action: $e');
    }
  }

  // Error events
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screen,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (screen != null) 'screen': screen,
        },
      );
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  // Performance events
  Future<void> logPerformance({
    required String operation,
    required int durationMs,
    bool? successful,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'performance',
        parameters: {
          'operation': operation,
          'duration_ms': durationMs,
          if (successful != null) 'successful': successful,
        },
      );
    } catch (e) {
      debugPrint('Failed to log performance: $e');
    }
  }

  // Feature usage events
  Future<void> logFeatureUsage(String featureName) async {
    try {
      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: {
          'feature_name': featureName,
        },
      );
    } catch (e) {
      debugPrint('Failed to log feature usage: $e');
    }
  }

  // Onboarding events
  Future<void> logOnboardingStep({
    required int stepNumber,
    required String stepName,
    required bool completed,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_step',
        parameters: {
          'step_number': stepNumber,
          'step_name': stepName,
          'completed': completed ? 1 : 0,
        },
      );
    } catch (e) {
      debugPrint('Failed to log onboarding step: $e');
    }
  }

  Future<void> logOnboardingComplete() async {
    try {
      await _analytics.logEvent(name: 'onboarding_complete');
    } catch (e) {
      debugPrint('Failed to log onboarding complete: $e');
    }
  }

  // Custom events for business intelligence
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Failed to log custom event: $e');
    }
  }
}
