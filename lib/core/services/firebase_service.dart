import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Initialize messaging
    await _initializeMessaging();
  }

  // Initialize Firebase Cloud Messaging
  static Future<void> _initializeMessaging() async {
    final messaging = FirebaseMessaging.instance;
    
    // Request permission for notifications
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Get FCM token
    await messaging.getToken();
    // FCM Token obtained successfully
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Background message handled: ${message.messageId}
  }

  // Collection references
  CollectionReference get users => firestore.collection('users');
  CollectionReference get vendors => firestore.collection('vendors');
  CollectionReference get products => firestore.collection('products');
  CollectionReference get reports => firestore.collection('reports');
  CollectionReference get notifications => firestore.collection('notifications');

  // Storage references
  Reference get usersStorage => storage.ref().child('users');
  Reference get vendorsStorage => storage.ref().child('vendors');
  Reference get productsStorage => storage.ref().child('products');
  Reference get reportsStorage => storage.ref().child('reports');

  // Analytics helper methods
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String userId) async {
    await analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await analytics.setUserProperty(name: name, value: value);
  }

  // Custom analytics events
  Future<void> logProductVerified(String productId, String vendorId) async {
    await logEvent('product_verified', {
      'product_id': productId,
      'vendor_id': vendorId,
    });
  }

  Future<void> logFraudReported(String reportType, String reportedItemId) async {
    await logEvent('fraud_reported', {
      'report_type': reportType,
      'reported_item_id': reportedItemId,
    });
  }

  Future<void> logVendorRegistered(String vendorId) async {
    await logEvent('vendor_registered', {
      'vendor_id': vendorId,
    });
  }

  Future<void> logUserSignUp(String method) async {
    await analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logUserLogin(String method) async {
    await analytics.logLogin(loginMethod: method);
  }
}
