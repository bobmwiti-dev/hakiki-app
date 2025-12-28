/// Fraud ViewModel
/// 
/// Manages fraud reporting state and business logic.
/// Handles fraud report creation, listing, and management.
library;

import 'package:flutter/foundation.dart';
import '../data/repositories/fraud_repository.dart';
import '../data/models/fraud_report_model.dart';
import '../core/utils/logger.dart';

class FraudViewModel extends ChangeNotifier {
  final FraudRepository _fraudRepository;

  FraudViewModel({
    required FraudRepository fraudRepository,
  }) : _fraudRepository = fraudRepository;

  // State
  List<FraudReportModel> _fraudReports = [];
  FraudReportModel? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<FraudReportModel> get fraudReports => _fraudReports;
  FraudReportModel? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create fraud report
  Future<bool> createFraudReport(FraudReportModel report) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _fraudRepository.createReport(report);
      await loadFraudReports();
      return true;
    } catch (e) {
      Logger.error('Failed to create fraud report', tag: 'FraudViewModel', error: e);
      _errorMessage = 'Failed to submit report: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load fraud reports
  Future<void> loadFraudReports({int limit = 20}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _fraudReports = await _fraudRepository.getRecentReports(limit: limit);
    } catch (e) {
      Logger.error('Failed to load fraud reports', tag: 'FraudViewModel', error: e);
      _errorMessage = 'Failed to load reports';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load fraud reports by user
  Future<void> loadFraudReportsByUser(String userId, {int limit = 20}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _fraudReports = await _fraudRepository.getReportsByReporter(userId, limit: limit);
    } catch (e) {
      Logger.error('Failed to load user fraud reports', tag: 'FraudViewModel', error: e);
      _errorMessage = 'Failed to load reports';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select report
  void selectReport(FraudReportModel report) {
    _selectedReport = report;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedReport = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

