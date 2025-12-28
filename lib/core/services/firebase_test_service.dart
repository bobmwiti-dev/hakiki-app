import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/logger.dart';

/// Service to test Firebase connectivity and basic operations
class FirebaseTestService {
  static final FirebaseTestService _instance = FirebaseTestService._internal();
  factory FirebaseTestService() => _instance;
  FirebaseTestService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Test all Firebase services connectivity
  Future<Map<String, bool>> testAllServices() async {
    final results = <String, bool>{};
    
    Logger.info('🧪 Starting Firebase services connectivity test...');
    
    // Test Firebase Auth
    results['auth'] = await _testAuth();
    
    // Test Firestore
    results['firestore'] = await _testFirestore();
    
    // Test Storage
    results['storage'] = await _testStorage();
    
    // Test Analytics
    results['analytics'] = await _testAnalytics();
    
    // Log summary
    final passedTests = results.values.where((test) => test).length;
    final totalTests = results.length;
    
    if (passedTests == totalTests) {
      Logger.info('✅ All Firebase services are working correctly ($passedTests/$totalTests)');
    } else {
      Logger.warning('⚠️ Some Firebase services failed ($passedTests/$totalTests passed)');
    }
    
    return results;
  }

  /// Test Firebase Authentication
  Future<bool> _testAuth() async {
    try {
      Logger.info('Testing Firebase Auth...');
      
      // Check if Auth is initialized
      final currentUser = _auth.currentUser;
      Logger.info('Current user: ${currentUser?.uid ?? 'Not signed in'}');
      
      // Test auth state changes stream
      final authStream = _auth.authStateChanges();
      await authStream.first.timeout(const Duration(seconds: 5));
      
      Logger.info('✅ Firebase Auth is working');
      return true;
    } catch (e) {
      Logger.error('❌ Firebase Auth test failed: $e');
      return false;
    }
  }

  /// Test Firestore Database
  Future<bool> _testFirestore() async {
    try {
      Logger.info('Testing Firestore...');
      
      // Test write operation
      final testDoc = _firestore.collection('test').doc('connectivity_test');
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
        'message': 'Firebase connectivity test',
      });
      
      // Test read operation
      final snapshot = await testDoc.get();
      if (!snapshot.exists) {
        throw Exception('Test document was not created');
      }
      
      // Test delete operation
      await testDoc.delete();
      
      Logger.info('✅ Firestore is working');
      return true;
    } catch (e) {
      Logger.error('❌ Firestore test failed: $e');
      return false;
    }
  }

  /// Test Firebase Storage
  Future<bool> _testStorage() async {
    try {
      Logger.info('Testing Firebase Storage...');
      
      // Test storage reference creation
      final storageRef = _storage.ref().child('test/connectivity_test.txt');
      
      // Test upload
      const testData = 'Firebase Storage connectivity test';
      await storageRef.putString(testData);
      
      // Test download
      final downloadedData = await storageRef.getData();
      if (downloadedData == null) {
        throw Exception('Failed to download test data');
      }
      
      // Test delete
      await storageRef.delete();
      
      Logger.info('✅ Firebase Storage is working');
      return true;
    } catch (e) {
      Logger.error('❌ Firebase Storage test failed: $e');
      return false;
    }
  }

  /// Test Firebase Analytics
  Future<bool> _testAnalytics() async {
    try {
      Logger.info('Testing Firebase Analytics...');
      
      // Test analytics event logging
      await _analytics.logEvent(
        name: 'firebase_test',
        parameters: {
          'test_type': 'connectivity',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      // Test user property setting
      await _analytics.setUserProperty(
        name: 'test_user',
        value: 'firebase_connectivity_test',
      );
      
      Logger.info('✅ Firebase Analytics is working');
      return true;
    } catch (e) {
      Logger.error('❌ Firebase Analytics test failed: $e');
      return false;
    }
  }

  /// Test specific Firestore collections used by the app
  Future<Map<String, bool>> testAppCollections() async {
    final results = <String, bool>{};
    
    Logger.info('🧪 Testing app-specific Firestore collections...');
    
    final collections = ['users', 'products', 'vendors', 'reports', 'fraud_reports'];
    
    for (final collection in collections) {
      try {
        // Test collection access
        final query = _firestore.collection(collection).limit(1);
        await query.get();
        
        results[collection] = true;
        Logger.info('✅ Collection "$collection" is accessible');
      } catch (e) {
        results[collection] = false;
        Logger.error('❌ Collection "$collection" test failed: $e');
      }
    }
    
    return results;
  }

  /// Test Firebase Auth methods used by the app
  Future<Map<String, bool>> testAuthMethods() async {
    final results = <String, bool>{};
    
    Logger.info('🧪 Testing Firebase Auth methods...');
    
    try {
      // Test anonymous sign in (safe for testing)
      final userCredential = await _auth.signInAnonymously();
      results['anonymous_signin'] = userCredential.user != null;
      Logger.info('✅ Anonymous sign-in works');
      
      // Test sign out
      await _auth.signOut();
      results['signout'] = _auth.currentUser == null;
      Logger.info('✅ Sign-out works');
      
    } catch (e) {
      Logger.error('❌ Auth methods test failed: $e');
      results['anonymous_signin'] = false;
      results['signout'] = false;
    }
    
    return results;
  }

  /// Generate a comprehensive Firebase health report
  Future<Map<String, dynamic>> generateHealthReport() async {
    final report = <String, dynamic>{};
    
    Logger.info('📊 Generating Firebase health report...');
    
    // Basic connectivity tests
    report['basic_services'] = await testAllServices();
    
    // App-specific tests
    report['app_collections'] = await testAppCollections();
    report['auth_methods'] = await testAuthMethods();
    
    // System info
    report['timestamp'] = DateTime.now().toIso8601String();
    report['firebase_auth_version'] = 'Latest'; // You can get actual version if needed
    report['firestore_version'] = 'Latest';
    report['storage_version'] = 'Latest';
    
    // Calculate overall health score
    final allTests = <bool>[];
    if (report['basic_services'] is Map) {
      allTests.addAll((report['basic_services'] as Map).values.cast<bool>());
    }
    if (report['app_collections'] is Map) {
      allTests.addAll((report['app_collections'] as Map).values.cast<bool>());
    }
    if (report['auth_methods'] is Map) {
      allTests.addAll((report['auth_methods'] as Map).values.cast<bool>());
    }
    
    final passedTests = allTests.where((test) => test).length;
    final totalTests = allTests.length;
    final healthScore = totalTests > 0 ? (passedTests / totalTests * 100).round() : 0;
    
    report['health_score'] = healthScore;
    report['passed_tests'] = passedTests;
    report['total_tests'] = totalTests;
    
    Logger.info('📊 Firebase health score: $healthScore% ($passedTests/$totalTests tests passed)');
    
    return report;
  }
}
