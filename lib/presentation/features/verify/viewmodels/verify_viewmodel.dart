import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/vendor_model.dart';

class VerifyViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final AnalyticsService _analyticsService;

  VerifyViewModel({
    required FirestoreService firestoreService,
    required AuthService authService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _authService = authService,
        _analyticsService = analyticsService;

  // State
  bool _isLoading = false;
  bool _isScanning = false;
  String? _error;
  ProductModel? _scannedProduct;
  UserModel? _currentUser;
  List<ProductModel> _recentScans = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String? get error => _error;
  ProductModel? get scannedProduct => _scannedProduct;
  UserModel? get currentUser => _currentUser;
  List<ProductModel> get recentScans => _recentScans;

  // Initialize
  Future<void> initialize() async {
    await _loadCurrentUser();
    await _loadRecentScans();
    await _analyticsService.logScreenView('verify');
  }

  // Load current user
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user data: $e');
    }
  }

  // Load recent scans
  Future<void> _loadRecentScans() async {
    // This would load from cache or recent scan history
    // For now, we'll keep it empty
    _recentScans = [];
    notifyListeners();
  }

  // Start scanning
  void startScanning() {
    _isScanning = true;
    _clearError();
    _scannedProduct = null;
    notifyListeners();
  }

  // Stop scanning
  void stopScanning() {
    _isScanning = false;
    notifyListeners();
  }

  // Scan barcode
  Future<void> scanBarcode(String barcode) async {
    _setLoading(true);
    _clearError();

    try {
      await _analyticsService.logProductScan(
        scanType: 'barcode',
        successful: false, // Will update based on result
      );

      final product = await _firestoreService.getProductByBarcode(barcode);
      
      if (product != null) {
        _scannedProduct = product;
        await _updateVerificationCount(product.id);
        await _analyticsService.logProductScan(
          scanType: 'barcode',
          successful: true,
          productId: product.id,
        );
        await _analyticsService.logProductVerification(
          productId: product.id,
          verified: product.isVerified,
          trustLevel: product.trustLevel,
        );
      } else {
        _setError('Product not found. This product may not be registered in our system.');
        await _analyticsService.logProductScan(
          scanType: 'barcode',
          successful: false,
        );
      }
    } catch (e) {
      _setError('Failed to scan barcode: $e');
      await _analyticsService.logProductScan(
        scanType: 'barcode',
        successful: false,
      );
    } finally {
      _setLoading(false);
      _isScanning = false;
    }
  }

  // Get vendor details
  Future<VendorModel?> getVendorDetails(String vendorId) async {
    try {
      return await _firestoreService.getVendor(vendorId);
    } catch (e) {
      _setError('Failed to load vendor details: $e');
      return null;
    }
  }

  // Save to scan history
  Future<void> saveToScanHistory(ProductModel product, String scannedCode) async {
    try {
      // Log scan to analytics instead of separate collection
      await _analyticsService.logProductScan(
        scanType: 'manual_save',
        successful: true,
        productId: product.id,
      );
    } catch (e) {
      _setError('Failed to save scan history: $e');
    }
  }

  // Scan QR code
  Future<void> scanQRCode(String qrCode) async {
    _setLoading(true);
    _clearError();

    try {
      await _analyticsService.logProductScan(
        scanType: 'qr_code',
        successful: false, // Will update based on result
      );

      final product = await _firestoreService.getProductByQRCode(qrCode);
      
      if (product != null) {
        _scannedProduct = product;
        await _updateVerificationCount(product.id);
        await _analyticsService.logProductScan(
          scanType: 'qr_code',
          successful: true,
          productId: product.id,
        );
        await _analyticsService.logProductVerification(
          productId: product.id,
          verified: product.isVerified,
          trustLevel: product.trustLevel,
        );
      } else {
        _setError('Product not found. This QR code may not be valid or the product is not registered.');
        await _analyticsService.logProductScan(
          scanType: 'qr_code',
          successful: false,
        );
      }
    } catch (e) {
      _setError('Failed to scan QR code: $e');
      await _analyticsService.logProductScan(
        scanType: 'qr_code',
        successful: false,
      );
    } finally {
      _setLoading(false);
      _isScanning = false;
    }
  }

  // Verify product by code (barcode or QR code)
  Future<ProductModel?> verifyProductByCode(String code) async {
    _setLoading(true);
    _clearError();

    try {
      // Try barcode first
      ProductModel? product = await _firestoreService.getProductByBarcode(code);
      
      // If not found, try QR code
      product ??= await _firestoreService.getProductByQRCode(code);
      
      if (product != null) {
        _scannedProduct = product;
        await _updateVerificationCount(product.id);
        await _analyticsService.logProductScan(
          scanType: code.length > 20 ? 'qr_code' : 'barcode',
          successful: true,
          productId: product.id,
        );
        await _analyticsService.logProductVerification(
          productId: product.id,
          verified: product.isVerified,
          trustLevel: product.trustLevel,
        );
        return product;
      } else {
        _setError('Product not found. This code may not be registered in our system.');
        await _analyticsService.logProductScan(
          scanType: code.length > 20 ? 'qr_code' : 'barcode',
          successful: false,
        );
        return null;
      }
    } catch (e) {
      _setError('Failed to verify product: $e');
      await _analyticsService.logProductScan(
        scanType: code.length > 20 ? 'qr_code' : 'barcode',
        successful: false,
      );
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Manual product search
  Future<void> searchProduct(String query) async {
    _setLoading(true);
    _clearError();

    try {
      await _analyticsService.logSearch(query);
      
      // For now, we'll implement a simple search by name
      // In a real app, you'd have a more sophisticated search
      
      // This is a placeholder - you'd need to implement proper search
      _setError('Manual search not yet implemented. Please use barcode or QR code scanning.');
    } catch (e) {
      _setError('Failed to search product: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update verification count
  Future<void> _updateVerificationCount(String productId) async {
    try {
      await _firestoreService.updateProduct(productId, {
        'verificationCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Failed to update verification count: $e');
    }
  }

  // Clear scanned product
  void clearScannedProduct() {
    _scannedProduct = null;
    _clearError();
    notifyListeners();
  }

  // Get trust level color
  String getTrustLevelColor(String trustLevel) {
    switch (trustLevel.toLowerCase()) {
      case 'high':
        return 'green';
      case 'medium':
        return 'orange';
      case 'low':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Get verification status message
  String getVerificationMessage(ProductModel product) {
    if (product.isVerified) {
      if (product.trustLevel == 'High') {
        return 'This product is verified and has a high trust score. It appears to be authentic.';
      } else if (product.trustLevel == 'Medium') {
        return 'This product is verified but has a medium trust score. Exercise caution.';
      } else {
        return 'This product is verified but has a low trust score. Be careful and consider reporting if suspicious.';
      }
    } else {
      return 'This product is not yet verified. Verification is pending or the product may be suspicious.';
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
    _analyticsService.logError(
      errorType: 'verify_error',
      errorMessage: error,
      screen: 'verify',
    );
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

}
