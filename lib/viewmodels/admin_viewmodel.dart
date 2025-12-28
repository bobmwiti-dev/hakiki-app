/// Admin ViewModel
///
/// Manages admin dashboard state and business logic.
/// Handles admin operations like vendor approval, report review, etc.
library;

import 'package:flutter/foundation.dart';
import '../data/repositories/admin_repository.dart';
import '../data/repositories/fraud_repository.dart';
import '../data/models/vendor_model.dart';
import '../data/models/fraud_report_model.dart';
import '../core/utils/logger.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;
  final FraudRepository _fraudRepository;

  AdminViewModel({
    required AdminRepository adminRepository,
    required FraudRepository fraudRepository,
  }) : _adminRepository = adminRepository,
       _fraudRepository = fraudRepository;

  // State
  List<VendorModel> _pendingVendors = [];
  List<FraudReportModel> _pendingReports = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<VendorModel> get pendingVendors => _pendingVendors;
  List<FraudReportModel> get pendingReports => _pendingReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load pending vendors
  Future<void> loadPendingVendors() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _pendingVendors = await _adminRepository.getPendingVendors();
    } catch (e) {
      Logger.error(
        'Failed to load pending vendors',
        tag: 'AdminViewModel',
        error: e,
      );
      _errorMessage = 'Failed to load pending vendors';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load pending reports
  Future<void> loadPendingReports() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _pendingReports = await _adminRepository.getPendingReports();
    } catch (e) {
      Logger.error(
        'Failed to load pending reports',
        tag: 'AdminViewModel',
        error: e,
      );
      _errorMessage = 'Failed to load pending reports';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve vendor
  Future<bool> approveVendor(String vendorId, String adminId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _adminRepository.approveVendor(vendorId, adminId);
      await loadPendingVendors();
      return true;
    } catch (e) {
      Logger.error('Failed to approve vendor', tag: 'AdminViewModel', error: e);
      _errorMessage = 'Failed to approve vendor';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject vendor
  Future<bool> rejectVendor(String vendorId, String reason) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _adminRepository.rejectVendor(vendorId, reason);
      await loadPendingVendors();
      return true;
    } catch (e) {
      Logger.error('Failed to reject vendor', tag: 'AdminViewModel', error: e);
      _errorMessage = 'Failed to reject vendor';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resolve report
  Future<bool> resolveReport(
    String reportId,
    String resolution,
    String assignedTo,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _fraudRepository.resolveReport(reportId, resolution, assignedTo);
      await loadPendingReports();
      return true;
    } catch (e) {
      Logger.error('Failed to resolve report', tag: 'AdminViewModel', error: e);
      _errorMessage = 'Failed to resolve report';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
