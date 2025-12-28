import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/vendor_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AnalyticsService _analyticsService;
  final CacheService _cacheService;

  ProfileViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
    required StorageService storageService,
    required AnalyticsService analyticsService,
    required CacheService cacheService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _storageService = storageService,
        _analyticsService = analyticsService,
        _cacheService = cacheService;

  // State
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  UserModel? _currentUser;
  VendorModel? _vendorProfile;
  Map<String, bool> _notificationPreferences = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  VendorModel? get vendorProfile => _vendorProfile;
  Map<String, bool> get notificationPreferences => _notificationPreferences;
  bool get isVendor => _currentUser?.role == 'vendor';
  bool get isAdmin => _currentUser?.role == 'admin';

  // Initialize
  Future<void> initialize() async {
    await _loadCurrentUser();
    await _loadVendorProfile();
    await _loadNotificationPreferences();
    await _analyticsService.logScreenView('profile');
  }

  // Load current user
  Future<void> _loadCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load vendor profile
  Future<void> _loadVendorProfile() async {
    if (_currentUser?.role != 'vendor') return;

    try {
      _vendorProfile = await _firestoreService.getVendorByUserId(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load vendor profile: $e');
    }
  }

  // Load notification preferences
  Future<void> _loadNotificationPreferences() async {
    _notificationPreferences = _cacheService.getNotificationPreferences();
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return false;

    _setUpdating(true);
    _clearError();

    try {
      // Update Firebase Auth profile
      await _authService.updateUserProfile(displayName: displayName);

      // Update Firestore user document
      await _firestoreService.updateUser(_currentUser!.id, {
        'displayName': displayName,
        'phoneNumber': phoneNumber,
      });

      // Reload user data
      await _loadCurrentUser();
      
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Update profile photo
  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_currentUser == null) return false;

    _setUpdating(true);
    _clearError();

    try {
      // Upload image
      final photoUrl = await _storageService.uploadProfileImage(
        imageFile,
        _currentUser!.id,
      );

      // Update Firebase Auth profile
      await _authService.updateUserProfile(photoUrl: photoUrl);

      // Update Firestore user document
      await _firestoreService.updateUser(_currentUser!.id, {
        'photoUrl': photoUrl,
      });

      // Reload user data
      await _loadCurrentUser();
      
      return true;
    } catch (e) {
      _setError('Failed to update profile photo: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    _notificationPreferences = preferences;
    await _cacheService.setNotificationPreferences(preferences);
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool isDark) async {
    await _cacheService.setDarkMode(isDark);
    notifyListeners();
  }

  // Get dark mode setting
  bool get isDarkMode => _cacheService.isDarkMode;

  // Sign out
  Future<bool> signOut() async {
    _setUpdating(true);
    try {
      await _authService.signOut();
      await _cacheService.clearAllCache();
      return true;
    } catch (e) {
      _setError('Failed to sign out: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    _setUpdating(true);
    _clearError();

    try {
      // This would require additional implementation for account deletion
      // Including deleting user data from Firestore, Storage, etc.
      _setError('Account deletion not yet implemented');
      return false;
    } catch (e) {
      _setError('Failed to delete account: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Get trust score color
  String getTrustScoreColor(int score) {
    if (score >= 80) return 'green';
    if (score >= 50) return 'orange';
    return 'red';
  }

  // Get trust score text
  String getTrustScoreText(int score) {
    if (score >= 80) return 'High Trust';
    if (score >= 50) return 'Medium Trust';
    return 'Low Trust';
  }

  // Get verification status text
  String getVerificationStatusText() {
    if (_currentUser == null) return 'Not Verified';
    
    if (_currentUser!.isVerified) {
      return 'Verified';
    } else {
      return 'Not Verified';
    }
  }

  // Get vendor status text
  String getVendorStatusText() {
    if (_vendorProfile == null) return 'Not a Vendor';
    
    switch (_vendorProfile!.verificationStatus) {
      case 'approved':
        return 'Approved Vendor';
      case 'pending':
        return 'Pending Approval';
      case 'rejected':
        return 'Application Rejected';
      case 'suspended':
        return 'Account Suspended';
      default:
        return 'Unknown Status';
    }
  }

  // Refresh profile data
  Future<void> refresh() async {
    await _loadCurrentUser();
    await _loadVendorProfile();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
    _analyticsService.logError(
      errorType: 'profile_error',
      errorMessage: error,
      screen: 'profile',
    );
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
