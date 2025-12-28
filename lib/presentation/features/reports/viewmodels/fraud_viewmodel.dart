import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/fraud_report_model.dart';
import '../../../../data/repositories/fraud_repository.dart';

class FraudViewModel extends ChangeNotifier {
  final FraudRepository _fraudRepository;

  FraudViewModel(this._fraudRepository);

  FraudReportModel? _currentReport;
  List<FraudReportModel> _reports = [];
  List<FraudReportModel> _userReports = [];
  List<FraudReportModel> _pendingReports = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _reportStats;

  // Getters
  FraudReportModel? get currentReport => _currentReport;
  List<FraudReportModel> get reports => _reports;
  List<FraudReportModel> get userReports => _userReports;
  List<FraudReportModel> get pendingReports => _pendingReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get reportStats => _reportStats;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setCurrentReport(FraudReportModel? report) {
    _currentReport = report;
    notifyListeners();
  }

  void _setReports(List<FraudReportModel> reports) {
    _reports = reports;
    notifyListeners();
  }

  void _setUserReports(List<FraudReportModel> reports) {
    _userReports = reports;
    notifyListeners();
  }

  void _setPendingReports(List<FraudReportModel> reports) {
    _pendingReports = reports;
    notifyListeners();
  }

  void _setReportStats(Map<String, dynamic>? stats) {
    _reportStats = stats;
    notifyListeners();
  }

  // Create fraud report
  Future<bool> createFraudReport(FraudReportModel report) async {
    try {
      Logger.info('Creating fraud report: ${report.title}', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final createdReport = await _fraudRepository.createReport(report);
      _setCurrentReport(createdReport);
      
      // Add to user reports list if it exists
      if (_userReports.isNotEmpty) {
        _userReports.insert(0, createdReport);
        notifyListeners();
      }
      
      Logger.info('Fraud report created successfully: ${createdReport.id}', tag: 'FraudViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to create fraud report: ${report.title}', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to submit fraud report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get report by ID
  Future<void> getReportById(String reportId) async {
    try {
      Logger.debug('Getting fraud report by ID: $reportId', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final report = await _fraudRepository.getReportById(reportId);
      _setCurrentReport(report);
      
      if (report != null) {
        Logger.debug('Fraud report found: ${report.title}', tag: 'FraudViewModel');
      } else {
        Logger.debug('Fraud report not found: $reportId', tag: 'FraudViewModel');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get fraud report by ID: $reportId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load fraud report');
    } finally {
      _setLoading(false);
    }
  }

  // Get reports by user
  Future<void> getReportsByUser(String userId, {int? limit}) async {
    try {
      Logger.debug('Getting fraud reports by user: $userId', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getReportsByReporter(userId, limit: limit);
      _setUserReports(reports);
      
      Logger.debug('Found ${reports.length} reports by user: $userId', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get reports by user: $userId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load user reports');
    } finally {
      _setLoading(false);
    }
  }

  // Get reports by status
  Future<void> getReportsByStatus(String status, {int? limit}) async {
    try {
      Logger.debug('Getting fraud reports by status: $status', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getReportsByStatus(status, limit: limit);
      
      if (status == 'pending') {
        _setPendingReports(reports);
      } else {
        _setReports(reports);
      }
      
      Logger.debug('Found ${reports.length} reports with status: $status', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get reports by status: $status', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load reports');
    } finally {
      _setLoading(false);
    }
  }

  // Get reports by product
  Future<void> getReportsByProduct(String productId, {int? limit}) async {
    try {
      Logger.debug('Getting fraud reports by product: $productId', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getReportsByProduct(productId, limit: limit);
      _setReports(reports);
      
      Logger.debug('Found ${reports.length} reports for product: $productId', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get reports by product: $productId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load product reports');
    } finally {
      _setLoading(false);
    }
  }

  // Get reports by vendor
  Future<void> getReportsByVendor(String vendorId, {int? limit}) async {
    try {
      Logger.debug('Getting fraud reports by vendor: $vendorId', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getReportsByVendor(vendorId, limit: limit);
      _setReports(reports);
      
      Logger.debug('Found ${reports.length} reports for vendor: $vendorId', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get reports by vendor: $vendorId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load vendor reports');
    } finally {
      _setLoading(false);
    }
  }

  // Get high severity reports
  Future<void> getHighSeverityReports({int minSeverity = 4, int? limit}) async {
    try {
      Logger.debug('Getting high severity reports (>= $minSeverity)', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getReportsBySeverity(minSeverity, limit: limit);
      _setReports(reports);
      
      Logger.debug('Found ${reports.length} high severity reports', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get high severity reports', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load high severity reports');
    } finally {
      _setLoading(false);
    }
  }

  // Get recent reports
  Future<void> getRecentReports({int limit = 10}) async {
    try {
      Logger.debug('Getting recent fraud reports', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final reports = await _fraudRepository.getRecentReports(limit: limit);
      _setReports(reports);
      
      Logger.debug('Found ${reports.length} recent reports', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent reports', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load recent reports');
    } finally {
      _setLoading(false);
    }
  }

  // Resolve report (Admin only)
  Future<bool> resolveReport(String reportId, String resolution, String assignedTo) async {
    try {
      Logger.info('Resolving fraud report: $reportId', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final resolvedReport = await _fraudRepository.resolveReport(reportId, resolution, assignedTo);
      
      // Update current report if it's the same
      if (_currentReport?.id == reportId) {
        _setCurrentReport(resolvedReport);
      }
      
      // Remove from pending list
      _pendingReports.removeWhere((r) => r.id == reportId);
      notifyListeners();
      
      Logger.info('Fraud report resolved successfully: $reportId', tag: 'FraudViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to resolve fraud report: $reportId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to resolve report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Dismiss report (Admin only)
  Future<bool> dismissReport(String reportId, String reason) async {
    try {
      Logger.info('Dismissing fraud report: $reportId', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final dismissedReport = await _fraudRepository.dismissReport(reportId, reason);
      
      // Update current report if it's the same
      if (_currentReport?.id == reportId) {
        _setCurrentReport(dismissedReport);
      }
      
      // Remove from pending list
      _pendingReports.removeWhere((r) => r.id == reportId);
      notifyListeners();
      
      Logger.info('Fraud report dismissed successfully: $reportId', tag: 'FraudViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to dismiss fraud report: $reportId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to dismiss report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Assign report to admin
  Future<bool> assignReport(String reportId, String assignedTo) async {
    try {
      Logger.info('Assigning fraud report: $reportId to $assignedTo', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final assignedReport = await _fraudRepository.assignReport(reportId, assignedTo);
      
      // Update current report if it's the same
      if (_currentReport?.id == reportId) {
        _setCurrentReport(assignedReport);
      }
      
      Logger.info('Fraud report assigned successfully: $reportId', tag: 'FraudViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to assign fraud report: $reportId', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to assign report');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get report statistics
  Future<void> getReportStatistics() async {
    try {
      Logger.debug('Getting fraud report statistics', tag: 'FraudViewModel');
      _setLoading(true);
      _setError(null);

      final stats = await _fraudRepository.getReportStats();
      _setReportStats(stats);
      
      Logger.debug('Report statistics retrieved', tag: 'FraudViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get report statistics', 
          tag: 'FraudViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load report statistics');
    } finally {
      _setLoading(false);
    }
  }

  // Get severity color
  String getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return 'green';
      case 2:
        return 'lightgreen';
      case 3:
        return 'orange';
      case 4:
        return 'red';
      case 5:
        return 'darkred';
      default:
        return 'grey';
    }
  }

  // Get status color
  String getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 'orange';
      case 'investigating':
        return 'blue';
      case 'resolved':
        return 'green';
      case 'dismissed':
        return 'grey';
      default:
        return 'grey';
    }
  }

  // Get report type display text
  String getReportTypeText(String type) {
    switch (type) {
      case 'fraud':
        return 'Fraud';
      case 'fake_product':
        return 'Fake Product';
      case 'scam':
        return 'Scam';
      case 'other':
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  void clearError() {
    _setError(null);
  }

  void clearReports() {
    _setReports([]);
  }

  void clearUserReports() {
    _setUserReports([]);
  }

  void clearPendingReports() {
    _setPendingReports([]);
  }
}
