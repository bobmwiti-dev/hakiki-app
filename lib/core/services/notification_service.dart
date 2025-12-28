import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class NotificationService {
  final FirebaseMessaging _messaging;

  NotificationService({required FirebaseMessaging messaging})
      : _messaging = messaging;

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // Get FCM token
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');

      // Configure foreground message handling
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configure background message handling
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Configure notification tap handling
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  // Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
    }
  }

  // Subscribe to user-specific topics
  Future<void> subscribeToUserTopics(String userId, String role) async {
    await subscribeToTopic('user_$userId');
    await subscribeToTopic('role_$role');
    
    if (role == AppConstants.adminRole) {
      await subscribeToTopic('admin_alerts');
      await subscribeToTopic('fraud_reports');
      await subscribeToTopic('vendor_applications');
    } else if (role == AppConstants.vendorRole) {
      await subscribeToTopic('vendor_updates');
    }
    
    await subscribeToTopic('general_alerts');
  }

  // Unsubscribe from user-specific topics
  Future<void> unsubscribeFromUserTopics(String userId, String role) async {
    await unsubscribeFromTopic('user_$userId');
    await unsubscribeFromTopic('role_$role');
    
    if (role == AppConstants.adminRole) {
      await unsubscribeFromTopic('admin_alerts');
      await unsubscribeFromTopic('fraud_reports');
      await unsubscribeFromTopic('vendor_applications');
    } else if (role == AppConstants.vendorRole) {
      await unsubscribeFromTopic('vendor_updates');
    }
    
    await unsubscribeFromTopic('general_alerts');
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Show local notification or handle in-app
    _showInAppNotification(message);
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Data: ${message.data}');

    // Navigate based on notification type
    _handleNotificationNavigation(message.data);
  }

  // Show in-app notification
  void _showInAppNotification(RemoteMessage message) {
    // In-app notification display would be implemented here
    // This could use flutter_local_notifications or custom overlay widgets
    debugPrint('Showing in-app notification: ${message.notification?.title}');
  }

  // Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case AppConstants.fraudAlert:
        // Navigate to fraud alert details
        _navigateToFraudAlert(id);
        break;
      case AppConstants.vendorApproval:
        // Navigate to vendor approval
        _navigateToVendorApproval(id);
        break;
      case AppConstants.trustScoreUpdate:
        // Navigate to profile
        _navigateToProfile();
        break;
      case AppConstants.reportUpdate:
        // Navigate to report details
        _navigateToReportDetails(id);
        break;
      default:
        // Navigate to home
        _navigateToHome();
    }
  }

  // Navigation methods (to be implemented with actual navigation)
  void _navigateToFraudAlert(String? alertId) {
    // Navigation to fraud alert details would be implemented here
    debugPrint('Navigate to fraud alert: $alertId');
  }

  void _navigateToVendorApproval(String? vendorId) {
    // Navigation to vendor approval screen would be implemented here
    debugPrint('Navigate to vendor approval: $vendorId');
  }

  void _navigateToProfile() {
    // Navigation to user profile would be implemented here
    debugPrint('Navigate to profile');
  }

  void _navigateToReportDetails(String? reportId) {
    // Navigation to report details screen would be implemented here
    debugPrint('Navigate to report details: $reportId');
  }

  void _navigateToHome() {
    // Navigation to home screen would be implemented here
    debugPrint('Navigate to home');
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be done from a backend service
    // For now, we'll just log the notification
    debugPrint('Send notification to user $userId: $title - $body');
  }

  // Send notification to topic
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be done from a backend service
    // For now, we'll just log the notification
    debugPrint('Send notification to topic $topic: $title - $body');
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}
