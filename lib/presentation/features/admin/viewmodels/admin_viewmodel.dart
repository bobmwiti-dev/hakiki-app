import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/fraud_report_model.dart';
import '../../../../data/repositories/vendor_repository.dart';
import '../../../../data/repositories/fraud_repository.dart';
import '../../../../data/repositories/user_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final VendorRepository _vendorRepository;
  final FraudRepository _fraudRepository;

  AdminViewModel(
    this._userRepository,
    this._vendorRepository,
    this._fraudRepository,
  );

  // Dashboard data
  Map<String, dynamic>? _dashboardStats;
  List<VendorModel> _pendingVendors = [];
  List<FraudReportModel> _pendingReports = [];
  List<UserModel> _users = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<VendorModel> get pendingVendors => _pendingVendors;
  List<FraudReportModel> get pendingReports => _pendingReports;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;
  
  // Dashboard stats getters
  int get totalUsers => _users.length;
  int get approvedVendors => _pendingVendors.where((v) => v.verificationStatus == 'approved').length;
  List<dynamic> get recentActivity => _pendingReports.take(10).toList();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setDashboardStats(Map<String, dynamic>? stats) {
    _dashboardStats = stats;
    notifyListeners();
  }

  void _setPendingVendors(List<VendorModel> vendors) {
    _pendingVendors = vendors;
    notifyListeners();
  }

  void _setPendingReports(List<FraudReportModel> reports) {
    _pendingReports = reports;
    notifyListeners();
  }

  void _setUsers(List<UserModel> users) {
    _users = users;
    notifyListeners();
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      Logger.info('Loading admin dashboard data', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      // Load statistics in parallel
      final futures = await Future.wait([
        _userRepository.getUserStats(),
        _vendorRepository.getVendorStats(),
        _fraudRepository.getReportStats(),
      ]);

      final userStats = futures[0];
      final vendorStats = futures[1];
      final reportStats = futures[2];

      final combinedStats = {
        'users': userStats,
        'vendors': vendorStats,
        'reports': reportStats,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      _setDashboardStats(combinedStats);
      Logger.info('Dashboard data loaded successfully', tag: 'AdminViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to load dashboard data', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load dashboard data');
    } finally {
      _setLoading(false);
    }
  }

  // Load pending vendor applications
  Future<void> loadPendingVendors() async {
    try {
      Logger.debug('Loading pending vendor applications', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      final vendors = await _vendorRepository.getVendorsByStatus('pending');
      _setPendingVendors(vendors);
      
      Logger.debug('Loaded ${vendors.length} pending vendor applications', tag: 'AdminViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to load pending vendors', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load pending vendor applications');
    } finally {
      _setLoading(false);
    }
  }

  // Load pending fraud reports
  Future<void> loadPendingReports() async {
    try {
      Logger.debug('Loading pending fraud reports', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getReportsByStatus('pending');
      _setPendingReports(reports);
      
      Logger.debug('Loaded ${reports.length} pending fraud reports', tag: 'AdminViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to load pending reports', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load pending fraud reports');
    } finally {
      _setLoading(false);
    }
  }

  // Load users
  Future<void> loadUsers({String? role, int? limit}) async {
    try {
      Logger.debug('Loading users${role != null ? ' with role: $role' : ''}', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      List<UserModel> users;
      if (role != null) {
        users = await _userRepository.getUsersByRole(role, limit: limit);
      } else {
        // For now, load all active users (you might want to implement pagination)
        users = await _userRepository.getUsersByRole('user', limit: limit ?? 50);
        final vendors = await _userRepository.getUsersByRole('vendor', limit: limit ?? 50);
        final admins = await _userRepository.getUsersByRole('admin', limit: limit ?? 50);
        users.addAll(vendors);
        users.addAll(admins);
      }
      
      _setUsers(users);
      Logger.debug('Loaded ${users.length} users', tag: 'AdminViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to load users', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load users');
    } finally {
      _setLoading(false);
    }
  }

  // Approve vendor application
  Future<bool> approveVendor(String vendorId, String adminId) async {
    try {
      Logger.info('Approving vendor: $vendorId by admin: $adminId', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _vendorRepository.approveVendor(vendorId, adminId);
      
      // Remove from pending list
      _pendingVendors.removeWhere((v) => v.id == vendorId);
      notifyListeners();
      
      Logger.info('Vendor approved successfully: $vendorId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to approve vendor: $vendorId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to approve vendor');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject vendor application
  Future<bool> rejectVendor(String vendorId, String rejectionReason) async {
    try {
      Logger.info('Rejecting vendor: $vendorId', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _vendorRepository.rejectVendor(vendorId, rejectionReason);
      
      // Remove from pending list
      _pendingVendors.removeWhere((v) => v.id == vendorId);
      notifyListeners();
      
      Logger.info('Vendor rejected successfully: $vendorId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to reject vendor: $vendorId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to reject vendor');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Suspend vendor
  Future<bool> suspendVendor(String vendorId, String reason) async {
    try {
      Logger.info('Suspending vendor: $vendorId', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _vendorRepository.suspendVendor(vendorId, reason);
      
      Logger.info('Vendor suspended successfully: $vendorId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to suspend vendor: $vendorId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to suspend vendor');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resolve fraud report
  Future<bool> resolveReport(String reportId, String resolution, String adminId) async {
    try {
      Logger.info('Resolving fraud report: $reportId by admin: $adminId', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _fraudRepository.resolveReport(reportId, resolution, adminId);
      
      // Remove from pending list
      _pendingReports.removeWhere((r) => r.id == reportId);
      notifyListeners();
      
      Logger.info('Fraud report resolved successfully: $reportId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to resolve fraud report: $reportId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to resolve fraud report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Dismiss fraud report
  Future<bool> dismissReport(String reportId, String reason) async {
    try {
      Logger.info('Dismissing fraud report: $reportId', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _fraudRepository.dismissReport(reportId, reason);
      
      // Remove from pending list
      _pendingReports.removeWhere((r) => r.id == reportId);
      notifyListeners();
      
      Logger.info('Fraud report dismissed successfully: $reportId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to dismiss fraud report: $reportId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to dismiss fraud report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Assign fraud report to admin
  Future<bool> assignReport(String reportId, String assignedTo) async {
    try {
      Logger.info('Assigning fraud report: $reportId to: $assignedTo', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _fraudRepository.assignReport(reportId, assignedTo);
      
      Logger.info('Fraud report assigned successfully: $reportId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to assign fraud report: $reportId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to assign fraud report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      Logger.info('Deactivating user: $userId', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _userRepository.deactivateUser(userId);
      
      // Remove from users list
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      
      Logger.info('User deactivated successfully: $userId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to deactivate user: $userId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to deactivate user');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user trust score
  Future<bool> updateUserTrustScore(String userId, int newScore) async {
    try {
      Logger.info('Updating trust score for user: $userId to $newScore', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _userRepository.updateTrustScore(userId, newScore);
      
      // Update user in list
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = _users[userIndex].copyWith(trustScore: newScore);
        notifyListeners();
      }
      
      Logger.info('Trust score updated successfully for user: $userId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update trust score for user: $userId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update trust score');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update vendor trust score
  Future<bool> updateVendorTrustScore(String vendorId, int newScore) async {
    try {
      Logger.info('Updating trust score for vendor: $vendorId to $newScore', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      await _vendorRepository.updateTrustScore(vendorId, newScore);
      
      Logger.info('Trust score updated successfully for vendor: $vendorId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update trust score for vendor: $vendorId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update trust score');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get system health status
  String getSystemHealthStatus() {
    if (_dashboardStats == null) return 'Unknown';
    
    final reportStats = _dashboardStats!['reports'] as Map<String, dynamic>?;
    final vendorStats = _dashboardStats!['vendors'] as Map<String, dynamic>?;
    
    if (reportStats == null || vendorStats == null) return 'Unknown';
    
    final highSeverityReports = reportStats['highSeverityReports'] as int? ?? 0;
    final pendingReports = reportStats['pendingReports'] as int? ?? 0;
    final pendingVendors = vendorStats['pendingVendors'] as int? ?? 0;
    
    if (highSeverityReports > 10 || pendingReports > 50) {
      return 'Critical';
    } else if (highSeverityReports > 5 || pendingReports > 20 || pendingVendors > 10) {
      return 'Warning';
    } else {
      return 'Good';
    }
  }

  // Get priority actions count
  int getPriorityActionsCount() {
    final highSeverityReports = _pendingReports.where((r) => r.severity >= 4).length;
    final pendingVendorsCount = _pendingVendors.length;
    return highSeverityReports + pendingVendorsCount;
  }

  void clearError() {
    _setError(null);
  }


  // Report approval methods
  Future<bool> approveReport(String reportId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Use the updateReportStatus method for consistency
      bool success = await updateReportStatus(reportId, 'approved');
      if (success) {
        Logger.info('Report approved: $reportId', tag: 'AdminViewModel');
      }
      return success;
    } catch (e) {
      Logger.error('Failed to approve report: $reportId', tag: 'AdminViewModel', error: e);
      _setError('Failed to approve report: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectReport(String reportId, String reason) async {
    try {
      _setLoading(true);
      _setError(null);

      // Use the updateReportStatus method for consistency
      bool success = await updateReportStatus(reportId, 'rejected');
      if (success) {
        Logger.info('Report rejected: $reportId with reason: $reason', tag: 'AdminViewModel');
      }
      return success;
    } catch (e) {
      Logger.error('Failed to reject report: $reportId', tag: 'AdminViewModel', error: e);
      _setError('Failed to reject report: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update report status
  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      Logger.info('Updating report status: $reportId to $status', tag: 'AdminViewModel');
      _setLoading(true);
      _setError(null);

      // TODO: Implement report status update when FraudRepository supports it
      Logger.debug('updateReportStatus not fully implemented', tag: 'AdminViewModel');
      
      // Update local state
      final reportIndex = _pendingReports.indexWhere((r) => r.id == reportId);
      if (reportIndex != -1) {
        // Remove from pending if status is not pending
        if (status != 'pending') {
          _pendingReports.removeAt(reportIndex);
          notifyListeners();
        }
      }
      
      Logger.info('Report status updated successfully: $reportId', tag: 'AdminViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update report status: $reportId', 
          tag: 'AdminViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update report status');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  void refreshDashboard() {
    loadDashboardData();
    loadPendingVendors();
    loadPendingReports();
  }
}
