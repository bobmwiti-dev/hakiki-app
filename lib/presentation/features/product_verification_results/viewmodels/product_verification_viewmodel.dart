import 'package:flutter/foundation.dart';

import '../../../../data/repositories/product_verification_repository.dart';
import '../../../../data/models/product_verification_model.dart';

class ProductVerificationViewModel extends ChangeNotifier {
  final ProductVerificationRepository _repository;

  ProductVerificationViewModel({
    required ProductVerificationRepository repository,
  }) : _repository = repository;

  // State variables
  ProductVerificationModel? _productVerification;
  List<ProductVerificationModel> _verificationHistory = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _errorMessage = '';

  // Getters
  ProductVerificationModel? get productVerification => _productVerification;
  List<ProductVerificationModel> get verificationHistory => _verificationHistory;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Methods
  Future<void> verifyProduct(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.verifyProduct(productId);
      _productVerification = result;
      _setOffline(false);
    } catch (e) {
      _setError('Failed to verify product. Please try again.');
      _setOffline(true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadVerificationHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final history = await _repository.getVerificationHistory();
      _verificationHistory = history;
      _setOffline(false);
    } catch (e) {
      _setError('Failed to load verification history.');
      _setOffline(true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reportFakeProduct(String productId, String reason) async {
    try {
      await _repository.reportFakeProduct(productId, reason);
      // Optionally refresh the product verification after reporting
      await verifyProduct(productId);
    } catch (e) {
      _setError('Failed to report fake product. Please try again.');
    }
  }

  Future<void> addToWatchlist(String productId) async {
    try {
      await _repository.addToWatchlist(productId);
    } catch (e) {
      _setError('Failed to add product to watchlist. Please try again.');
    }
  }

  Future<void> refreshData() async {
    if (_productVerification != null) {
      await verifyProduct(_productVerification!.id);
    }
  }

  void clearProductVerification() {
    _productVerification = null;
    _clearError();
    notifyListeners();
  }

  // Risk assessment helpers
  int get highRiskCount {
    if (_productVerification == null) return 0;
    return _productVerification!.riskIndicators
        .where((risk) => risk.severity == RiskSeverity.high)
        .length;
  }

  int get mediumRiskCount {
    if (_productVerification == null) return 0;
    return _productVerification!.riskIndicators
        .where((risk) => risk.severity == RiskSeverity.medium)
        .length;
  }

  int get lowRiskCount {
    if (_productVerification == null) return 0;
    return _productVerification!.riskIndicators
        .where((risk) => risk.severity == RiskSeverity.low)
        .length;
  }

  String get overallRiskLevel {
    if (highRiskCount > 0) return 'High Risk';
    if (mediumRiskCount > 0) return 'Medium Risk';
    return 'Low Risk';
  }

  // Verification status helpers
  bool get isAuthentic => _productVerification?.verificationStatus == VerificationStatus.authentic;
  bool get isSuspicious => _productVerification?.verificationStatus == VerificationStatus.suspicious;
  bool get isUnknown => _productVerification?.verificationStatus == VerificationStatus.unknown;

  String get statusMessage {
    if (_productVerification == null) return 'No verification data';
    
    switch (_productVerification!.verificationStatus) {
      case VerificationStatus.authentic:
        return 'Product Verified as Authentic';
      case VerificationStatus.suspicious:
        return 'Suspicious Product Detected';
      case VerificationStatus.unknown:
        return 'Verification Status Unknown';
    }
  }

  // Trust score helpers
  double get averageTrustScore {
    if (_productVerification == null || _productVerification!.verificationHistory.isEmpty) {
      return 0.0;
    }
    
    final scores = _productVerification!.verificationHistory.map((v) => v.trustScore);
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  int get totalVerifications => _productVerification?.verificationHistory.length ?? 0;

  // Similar reports helpers
  int get authenticReportsCount {
    if (_productVerification == null) return 0;
    return _productVerification!.similarReports
        .where((report) => report.type == ReportType.authentic)
        .fold(0, (sum, report) => sum + report.count);
  }

  int get fakeReportsCount {
    if (_productVerification == null) return 0;
    return _productVerification!.similarReports
        .where((report) => report.type == ReportType.fake)
        .fold(0, (sum, report) => sum + report.count);
  }

  int get suspiciousReportsCount {
    if (_productVerification == null) return 0;
    return _productVerification!.similarReports
        .where((report) => report.type == ReportType.suspicious)
        .fold(0, (sum, report) => sum + report.count);
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

  void _setOffline(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

}
