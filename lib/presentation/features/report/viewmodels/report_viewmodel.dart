import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../data/models/report_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

class ReportViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AuthService _authService;
  final AnalyticsService _analyticsService;
  final Uuid _uuid = const Uuid();

  ReportViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required AuthService authService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService,
        _authService = authService,
        _analyticsService = analyticsService;

  // State
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  UserModel? _currentUser;
  List<ReportModel> _userReports = [];
  final List<File> _selectedMedia = [];
  String _reportType = AppConstants.fraudReport;
  String _title = '';
  String _description = '';
  int _severity = 3;
  bool _isAnonymous = false;
  String? _productId;
  String? _vendorId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  List<ReportModel> get userReports => _userReports;
  List<File> get selectedMedia => _selectedMedia;
  String get reportType => _reportType;
  String get title => _title;
  String get description => _description;
  int get severity => _severity;
  bool get isAnonymous => _isAnonymous;
  String? get productId => _productId;
  String? get vendorId => _vendorId;

  // Initialize
  Future<void> initialize() async {
    await _loadCurrentUser();
    await _loadUserReports();
    await _analyticsService.logScreenView('report');
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

  // Load user reports
  Future<void> _loadUserReports() async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      _firestoreService.getReportsByUser(_currentUser!.id).listen((reports) {
        _userReports = reports;
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set report type
  void setReportType(String type) {
    _reportType = type;
    notifyListeners();
  }

  // Set title
  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  // Set description
  void setDescription(String description) {
    _description = description;
    notifyListeners();
  }

  // Set severity
  void setSeverity(int severity) {
    _severity = severity;
    notifyListeners();
  }

  // Set anonymous
  void setAnonymous(bool anonymous) {
    _isAnonymous = anonymous;
    notifyListeners();
  }

  // Set product ID
  void setProductId(String? productId) {
    _productId = productId;
    notifyListeners();
  }

  // Set vendor ID
  void setVendorId(String? vendorId) {
    _vendorId = vendorId;
    notifyListeners();
  }

  // Add media file
  void addMediaFile(File file) {
    if (_selectedMedia.length < AppConstants.maxImagesPerReport) {
      if (_storageService.validateImageFile(file)) {
        _selectedMedia.add(file);
        notifyListeners();
      } else {
        _setError('Invalid file. Please select a valid image file under ${AppConstants.maxFileSize / (1024 * 1024)}MB.');
      }
    } else {
      _setError('Maximum ${AppConstants.maxImagesPerReport} files allowed.');
    }
  }

  // Remove media file
  void removeMediaFile(int index) {
    if (index >= 0 && index < _selectedMedia.length) {
      _selectedMedia.removeAt(index);
      notifyListeners();
    }
  }

  // Clear all media
  void clearMedia() {
    _selectedMedia.clear();
    notifyListeners();
  }

  // Submit report
  Future<bool> submitReport() async {
    if (_currentUser == null) {
      _setError('You must be logged in to submit a report');
      return false;
    }

    if (_title.trim().isEmpty || _description.trim().isEmpty) {
      _setError('Please fill in all required fields');
      return false;
    }

    _setSubmitting(true);
    _clearError();

    try {
      final reportId = _uuid.v4();
      
      // Upload media files
      List<String> mediaUrls = [];
      if (_selectedMedia.isNotEmpty) {
        mediaUrls = await _storageService.uploadMultipleFiles(
          _selectedMedia,
          AppConstants.reportMediaPath,
          reportId,
        );
      }

      // Create report
      final report = ReportModel(
        id: reportId,
        reporterId: _currentUser!.id,
        productId: _productId,
        vendorId: _vendorId,
        type: _reportType,
        title: _title.trim(),
        description: _description.trim(),
        mediaUrls: mediaUrls,
        status: AppConstants.pendingStatus,
        severity: _severity,
        isAnonymous: _isAnonymous,
        evidence: {
          'user_agent': 'mobile_app',
          'timestamp': DateTime.now().toIso8601String(),
          'location': null, // Could add location if needed
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createReport(report);

      // Log analytics
      await _analyticsService.logFraudReport(
        reportType: _reportType,
        severity: _getSeverityText(_severity),
        productId: _productId,
        vendorId: _vendorId,
      );

      // Clear form
      _clearForm();
      
      return true;
    } catch (e) {
      _setError('Failed to submit report: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Clear form
  void _clearForm() {
    _reportType = AppConstants.fraudReport;
    _title = '';
    _description = '';
    _severity = 3;
    _isAnonymous = false;
    _productId = null;
    _vendorId = null;
    _selectedMedia.clear();
    notifyListeners();
  }

  // Get severity text
  String _getSeverityText(int severity) {
    switch (severity) {
      case 1:
        return 'Low';
      case 2:
        return 'Minor';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  // Get report type display name
  String getReportTypeDisplayName(String type) {
    switch (type) {
      case AppConstants.fraudReport:
        return 'Fraud';
      case AppConstants.fakeProductReport:
        return 'Fake Product';
      case AppConstants.scamReport:
        return 'Scam';
      case AppConstants.otherReport:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  // Get status display name
  String getStatusDisplayName(String status) {
    switch (status) {
      case AppConstants.pendingStatus:
        return 'Pending';
      case 'investigating':
        return 'Investigating';
      case 'resolved':
        return 'Resolved';
      case 'dismissed':
        return 'Dismissed';
      default:
        return 'Unknown';
    }
  }

  // Refresh reports
  Future<void> refresh() async {
    await _loadUserReports();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
    _analyticsService.logError(
      errorType: 'report_error',
      errorMessage: error,
      screen: 'report',
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
