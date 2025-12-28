import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class CacheService {
  final SharedPreferences _prefs;
  late Box _userBox;
  late Box _productBox;
  late Box _reportBox;

  CacheService({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  // Initialize Hive boxes
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    _userBox = await Hive.openBox('users');
    _productBox = await Hive.openBox('products');
    _reportBox = await Hive.openBox('reports');
  }

  // SharedPreferences operations
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String> getStringList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // App-specific preferences
  bool get isFirstLaunch => getBool(AppConstants.isFirstLaunchKey, defaultValue: true);
  Future<void> setFirstLaunchComplete() => setBool(AppConstants.isFirstLaunchKey, false);

  bool get isDarkMode => getBool(AppConstants.isDarkModeKey);
  Future<void> setDarkMode(bool isDark) => setBool(AppConstants.isDarkModeKey, isDark);

  String? get userRole => getString(AppConstants.userRoleKey);
  Future<void> setUserRole(String role) => setString(AppConstants.userRoleKey, role);

  DateTime? get lastSync {
    final timestamp = getString(AppConstants.lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  Future<void> setLastSync(DateTime dateTime) => 
      setString(AppConstants.lastSyncKey, dateTime.toIso8601String());

  // Hive operations for complex data
  Future<void> cacheUser(String userId, Map<String, dynamic> userData) async {
    await _userBox.put(userId, json.encode(userData));
  }

  Map<String, dynamic>? getCachedUser(String userId) {
    final data = _userBox.get(userId);
    return data != null ? json.decode(data) : null;
  }

  Future<void> cacheProduct(String productId, Map<String, dynamic> productData) async {
    await _productBox.put(productId, json.encode(productData));
  }

  Map<String, dynamic>? getCachedProduct(String productId) {
    final data = _productBox.get(productId);
    return data != null ? json.decode(data) : null;
  }

  Future<void> cacheReport(String reportId, Map<String, dynamic> reportData) async {
    await _reportBox.put(reportId, json.encode(reportData));
  }

  Map<String, dynamic>? getCachedReport(String reportId) {
    final data = _reportBox.get(reportId);
    return data != null ? json.decode(data) : null;
  }

  // Cache recent searches
  Future<void> addRecentSearch(String query) async {
    final recentSearches = getStringList('recent_searches');
    recentSearches.remove(query); // Remove if exists
    recentSearches.insert(0, query); // Add to beginning
    
    // Keep only last 10 searches
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    
    await setStringList('recent_searches', recentSearches);
  }

  List<String> getRecentSearches() {
    return getStringList('recent_searches');
  }

  Future<void> clearRecentSearches() async {
    await remove('recent_searches');
  }

  // Cache scanned products
  Future<void> addScannedProduct(String productId) async {
    final scannedProducts = getStringList('scanned_products');
    scannedProducts.remove(productId); // Remove if exists
    scannedProducts.insert(0, productId); // Add to beginning
    
    // Keep only last 50 scanned products
    if (scannedProducts.length > 50) {
      scannedProducts.removeRange(50, scannedProducts.length);
    }
    
    await setStringList('scanned_products', scannedProducts);
  }

  List<String> getScannedProducts() {
    return getStringList('scanned_products');
  }

  // Cache user preferences
  Future<void> setNotificationPreferences(Map<String, bool> preferences) async {
    await setString('notification_preferences', json.encode(preferences));
  }

  Map<String, bool> getNotificationPreferences() {
    final data = getString('notification_preferences');
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    return {
      'fraud_alerts': true,
      'vendor_updates': true,
      'trust_score_updates': true,
      'general_notifications': true,
    };
  }

  // Clear all cached data
  Future<void> clearAllCache() async {
    await Future.wait([
      _userBox.clear(),
      _productBox.clear(),
      _reportBox.clear(),
      clear(),
    ]);
  }

  // Get cache size
  int getCacheSize() {
    return _userBox.length + _productBox.length + _reportBox.length;
  }

  // Check if data is stale
  bool isDataStale(String key, {Duration maxAge = const Duration(hours: 1)}) {
    final timestamp = getString('${key}_timestamp');
    if (timestamp == null) return true;
    
    final cachedTime = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedTime) > maxAge;
  }

  // Set data with timestamp
  Future<void> setDataWithTimestamp(String key, String value) async {
    await setString(key, value);
    await setString('${key}_timestamp', DateTime.now().toIso8601String());
  }
}
