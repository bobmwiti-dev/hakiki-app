import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'analytics_service.dart';
import 'dependency_injection.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final AnalyticsService _analyticsService = getIt<AnalyticsService>();

  // Initialize push notifications
  static Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Subscribe to default topics
      await _subscribeToDefaultTopics();

    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channels for Android
    if (!kIsWeb) {
      await _createNotificationChannels();
    }
  }

  // Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel fraudAlertChannel = AndroidNotificationChannel(
      'fraud_alerts',
      'Fraud Alerts',
      description: 'Notifications about fraud reports and security alerts',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('alert_sound'),
    );

    const AndroidNotificationChannel vendorUpdatesChannel = AndroidNotificationChannel(
      'vendor_updates',
      'Vendor Updates',
      description: 'Updates about vendor verification status',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(fraudAlertChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(vendorUpdatesChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  // Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling a background message: ${message.messageId}');
    
    // Log analytics
    await _analyticsService.logCustomEvent(
      eventName: 'notification_received_background',
      parameters: {
        'message_id': message.messageId ?? 'unknown',
        'notification_type': message.data['type'] ?? 'unknown',
      },
    );

    // Show local notification
    await _showLocalNotification(message);
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}');
    }

    // Log analytics
    await _analyticsService.logCustomEvent(
      eventName: 'notification_received_foreground',
      parameters: {
        'message_id': message.messageId ?? 'unknown',
        'notification_type': message.data['type'] ?? 'unknown',
      },
    );

    // Show local notification for foreground messages
    await _showLocalNotification(message);
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final notificationType = message.data['type'] ?? 'general';
    String channelId = 'general';
    
    switch (notificationType) {
      case 'fraud_alert':
      case 'security_alert':
        channelId = 'fraud_alerts';
        break;
      case 'vendor_approved':
      case 'vendor_rejected':
      case 'vendor_update':
        channelId = 'vendor_updates';
        break;
      default:
        channelId = 'general';
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: channelId == 'fraud_alerts' ? Importance.high : Importance.defaultImportance,
      priority: channelId == 'fraud_alerts' ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1976D2), // AppTheme.primaryBlue
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    debugPrint('Notification tapped: ${message.data}');
    
    // Log analytics
    await _analyticsService.logCustomEvent(
      eventName: 'notification_tapped',
      parameters: {
        'message_id': message.messageId ?? 'unknown',
        'notification_type': message.data['type'] ?? 'unknown',
      },
    );

    // Navigate based on notification type
    await _navigateFromNotification(message.data);
  }

  // Handle local notification tap
  static void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    
    // Parse payload and navigate
    if (response.payload != null) {
      // This would typically parse the payload and navigate to the appropriate screen
      debugPrint('Navigating from local notification: ${response.payload}');
    }
  }

  // Navigate based on notification data
  static Future<void> _navigateFromNotification(Map<String, dynamic> data) async {
    final type = data['type'];
    
    switch (type) {
      case 'fraud_alert':
        // Navigate to fraud alert details
        debugPrint('Navigate to fraud alert: ${data['alert_id']}');
        break;
      case 'vendor_approved':
        // Navigate to vendor dashboard
        debugPrint('Navigate to vendor dashboard');
        break;
      case 'vendor_rejected':
        // Navigate to vendor registration with rejection details
        debugPrint('Navigate to vendor registration');
        break;
      case 'product_flagged':
        // Navigate to product details
        debugPrint('Navigate to product: ${data['product_id']}');
        break;
      case 'report_update':
        // Navigate to report details
        debugPrint('Navigate to report: ${data['report_id']}');
        break;
      default:
        // Navigate to home or appropriate default screen
        debugPrint('Navigate to home screen');
    }
  }

  // Subscribe to default topics
  static Future<void> _subscribeToDefaultTopics() async {
    try {
      // Subscribe to general announcements
      await _firebaseMessaging.subscribeToTopic('general_announcements');
      
      // Subscribe to security alerts
      await _firebaseMessaging.subscribeToTopic('security_alerts');
      
      debugPrint('Subscribed to default topics');
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  // Subscribe to user-specific topics
  static Future<void> subscribeToUserTopics(String userId, String userRole) async {
    try {
      // Subscribe to user-specific notifications
      await _firebaseMessaging.subscribeToTopic('user_$userId');
      
      // Subscribe to role-specific notifications
      switch (userRole) {
        case 'vendor':
          await _firebaseMessaging.subscribeToTopic('vendor_updates');
          break;
        case 'admin':
          await _firebaseMessaging.subscribeToTopic('admin_alerts');
          await _firebaseMessaging.subscribeToTopic('moderation_queue');
          break;
        default:
          await _firebaseMessaging.subscribeToTopic('user_updates');
      }
      
      debugPrint('Subscribed to user topics for role: $userRole');
    } catch (e) {
      debugPrint('Error subscribing to user topics: $e');
    }
  }

  // Unsubscribe from user topics (on logout)
  static Future<void> unsubscribeFromUserTopics(String userId, String userRole) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('user_$userId');
      
      switch (userRole) {
        case 'vendor':
          await _firebaseMessaging.unsubscribeFromTopic('vendor_updates');
          break;
        case 'admin':
          await _firebaseMessaging.unsubscribeFromTopic('admin_alerts');
          await _firebaseMessaging.unsubscribeFromTopic('moderation_queue');
          break;
        default:
          await _firebaseMessaging.unsubscribeFromTopic('user_updates');
      }
      
      debugPrint('Unsubscribed from user topics');
    } catch (e) {
      debugPrint('Error unsubscribing from user topics: $e');
    }
  }

  // Send notification to specific user (server-side function)
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be handled by Firebase Functions
    // For now, we'll just log the intent
    debugPrint('Would send notification to user $userId: $title');
    
    await _analyticsService.logCustomEvent(
      eventName: 'notification_sent',
      parameters: {
        'recipient_user_id': userId,
        'notification_type': type,
        'title': title,
      },
    );
  }

  // Send notification to topic (server-side function)
  static Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be handled by Firebase Functions
    debugPrint('Would send notification to topic $topic: $title');
    
    await _analyticsService.logCustomEvent(
      eventName: 'topic_notification_sent',
      parameters: {
        'topic': topic,
        'notification_type': type,
        'title': title,
      },
    );
  }

  // Get FCM token
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Update notification preferences
  static Future<void> updateNotificationPreferences({
    required bool fraudAlerts,
    required bool vendorUpdates,
    required bool generalUpdates,
    required bool marketingMessages,
  }) async {
    try {
      // Subscribe/unsubscribe based on preferences
      if (fraudAlerts) {
        await _firebaseMessaging.subscribeToTopic('fraud_alerts');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('fraud_alerts');
      }

      if (vendorUpdates) {
        await _firebaseMessaging.subscribeToTopic('vendor_updates');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('vendor_updates');
      }

      if (generalUpdates) {
        await _firebaseMessaging.subscribeToTopic('general_updates');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('general_updates');
      }

      if (marketingMessages) {
        await _firebaseMessaging.subscribeToTopic('marketing');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('marketing');
      }

      debugPrint('Updated notification preferences');
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }

  // Helper methods
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case 'fraud_alerts':
        return 'Fraud Alerts';
      case 'vendor_updates':
        return 'Vendor Updates';
      default:
        return 'General Notifications';
    }
  }

  static String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'fraud_alerts':
        return 'Important security and fraud alerts';
      case 'vendor_updates':
        return 'Updates about vendor verification and status';
      default:
        return 'General app notifications and updates';
    }
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Clear specific notification
  static Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
