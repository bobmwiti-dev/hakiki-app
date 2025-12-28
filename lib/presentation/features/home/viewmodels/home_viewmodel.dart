import 'package:flutter/foundation.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/product_verification_model.dart';
import '../../../../data/models/report_model.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  HomeViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService;

  // State variables
  UserModel? _currentUser;
  List<ProductVerificationModel> _recentVerifications = [];
  List<ReportModel> _recentReports = [];
  List<VendorModel> _verifiedVendors = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  UserModel? get currentUser => _currentUser;
  List<ProductVerificationModel> get recentVerifications => _recentVerifications;
  List<ReportModel> get recentReports => _recentReports;
  List<VendorModel> get verifiedVendors => _verifiedVendors;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Dashboard stats for admin/vendor users
  Map<String, dynamic> get dashboardStats => {
    'totalUsers': 0,
    'totalProducts': 0,
    'totalReports': 0,
    'pendingReviews': 0,
  };

  // Methods
  Future<void> initialize() async {
    await loadData();
  }

  Future<void> loadData() async {
    await loadUserData();
    await loadRecentReports();
    await loadVerifiedVendors();
  }

  Future<void> loadUserData() async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        _currentUser = await _firestoreService.getUser(userId);
        await loadRecentVerifications();
      }
    } catch (e) {
      _setError('Failed to load user data. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRecentVerifications() async {
    try {
      // This would typically load recent verifications from the database
      // For now, we'll use an empty list
      _recentVerifications = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recent verifications.');
    }
  }

  Future<void> loadRecentReports() async {
    try {
      // Load recent reports from Firestore
      _recentReports = await _firestoreService.getReports(limit: 10);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recent reports.');
    }
  }

  Future<void> loadVerifiedVendors() async {
    try {
      // Load verified vendors from Firestore
      _verifiedVendors = await _firestoreService.getVendors(limit: 10);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load verified vendors.');
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
