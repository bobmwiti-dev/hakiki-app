import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../data/repositories/vendor_repository.dart';

class VendorViewModel extends ChangeNotifier {
  final VendorRepository _vendorRepository;

  VendorViewModel(this._vendorRepository);

  VendorModel? _currentVendor;
  List<VendorModel> _vendors = [];
  List<VendorModel> _pendingVendors = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _vendorStats;

  // Getters
  VendorModel? get currentVendor => _currentVendor;
  List<VendorModel> get vendors => _vendors;
  List<VendorModel> get pendingVendors => _pendingVendors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get vendorStats => _vendorStats;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setCurrentVendor(VendorModel? vendor) {
    _currentVendor = vendor;
    notifyListeners();
  }

  void _setVendors(List<VendorModel> vendors) {
    _vendors = vendors;
    notifyListeners();
  }

  void _setPendingVendors(List<VendorModel> vendors) {
    _pendingVendors = vendors;
    notifyListeners();
  }

  void _setVendorStats(Map<String, dynamic>? stats) {
    _vendorStats = stats;
    notifyListeners();
  }

  // Create vendor application
  Future<bool> createVendorApplication(VendorModel vendor) async {
    try {
      Logger.info('Creating vendor application: ${vendor.businessName}', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final createdVendor = await _vendorRepository.createVendor(vendor);
      _setCurrentVendor(createdVendor);
      
      Logger.info('Vendor application created successfully: ${createdVendor.id}', tag: 'VendorViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to create vendor application: ${vendor.businessName}', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to submit vendor application');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get vendor by user ID
  Future<void> getVendorByUserId(String userId) async {
    try {
      Logger.debug('Getting vendor by user ID: $userId', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final vendor = await _vendorRepository.getVendorByUserId(userId);
      _setCurrentVendor(vendor);
      
      if (vendor != null) {
        Logger.debug('Vendor found: ${vendor.businessName}', tag: 'VendorViewModel');
      } else {
        Logger.debug('No vendor found for user: $userId', tag: 'VendorViewModel');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendor by user ID: $userId', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load vendor information');
    } finally {
      _setLoading(false);
    }
  }

  // Get vendor by ID
  Future<void> getVendorById(String vendorId) async {
    try {
      Logger.debug('Getting vendor by ID: $vendorId', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final vendor = await _vendorRepository.getVendorById(vendorId);
      _setCurrentVendor(vendor);
      
      if (vendor != null) {
        Logger.debug('Vendor found: ${vendor.businessName}', tag: 'VendorViewModel');
      } else {
        Logger.debug('Vendor not found: $vendorId', tag: 'VendorViewModel');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendor by ID: $vendorId', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load vendor information');
    } finally {
      _setLoading(false);
    }
  }

  // Update vendor
  Future<bool> updateVendor(VendorModel vendor) async {
    try {
      Logger.info('Updating vendor: ${vendor.id}', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final updatedVendor = await _vendorRepository.updateVendor(vendor);
      _setCurrentVendor(updatedVendor);
      
      Logger.info('Vendor updated successfully: ${vendor.id}', tag: 'VendorViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update vendor: ${vendor.id}', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update vendor information');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get vendors by status
  Future<void> getVendorsByStatus(String status, {int? limit}) async {
    try {
      Logger.debug('Getting vendors by status: $status', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final vendors = await _vendorRepository.getVendorsByStatus(status, limit: limit);
      
      if (status == 'pending') {
        _setPendingVendors(vendors);
      } else {
        _setVendors(vendors);
      }
      
      Logger.debug('Found ${vendors.length} vendors with status: $status', tag: 'VendorViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendors by status: $status', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load vendors');
    } finally {
      _setLoading(false);
    }
  }

  // Search vendors
  Future<void> searchVendors(String query, {int? limit}) async {
    try {
      Logger.debug('Searching vendors with query: $query', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final vendors = await _vendorRepository.searchVendors(query, limit: limit);
      _setVendors(vendors);
      
      Logger.debug('Found ${vendors.length} vendors matching query: $query', tag: 'VendorViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to search vendors with query: $query', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to search vendors');
    } finally {
      _setLoading(false);
    }
  }

  // Get top vendors
  Future<void> getTopVendors({int limit = 10}) async {
    try {
      Logger.debug('Getting top vendors', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final vendors = await _vendorRepository.getTopVendors(limit: limit);
      _setVendors(vendors);
      
      Logger.debug('Found ${vendors.length} top vendors', tag: 'VendorViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get top vendors', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load top vendors');
    } finally {
      _setLoading(false);
    }
  }

  // Approve vendor (Admin only)
  Future<bool> approveVendor(String vendorId, String approvedBy) async {
    try {
      Logger.info('Approving vendor: $vendorId', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final approvedVendor = await _vendorRepository.approveVendor(vendorId, approvedBy);
      
      // Update current vendor if it's the same
      if (_currentVendor?.id == vendorId) {
        _setCurrentVendor(approvedVendor);
      }
      
      // Remove from pending list
      _pendingVendors.removeWhere((v) => v.id == vendorId);
      notifyListeners();
      
      Logger.info('Vendor approved successfully: $vendorId', tag: 'VendorViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to approve vendor: $vendorId', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to approve vendor');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject vendor (Admin only)
  Future<bool> rejectVendor(String vendorId, String rejectionReason) async {
    try {
      Logger.info('Rejecting vendor: $vendorId', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final rejectedVendor = await _vendorRepository.rejectVendor(vendorId, rejectionReason);
      
      // Update current vendor if it's the same
      if (_currentVendor?.id == vendorId) {
        _setCurrentVendor(rejectedVendor);
      }
      
      // Remove from pending list
      _pendingVendors.removeWhere((v) => v.id == vendorId);
      notifyListeners();
      
      Logger.info('Vendor rejected successfully: $vendorId', tag: 'VendorViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to reject vendor: $vendorId', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to reject vendor');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Suspend vendor (Admin only)
  Future<bool> suspendVendor(String vendorId, String reason) async {
    try {
      Logger.info('Suspending vendor: $vendorId', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final suspendedVendor = await _vendorRepository.suspendVendor(vendorId, reason);
      
      // Update current vendor if it's the same
      if (_currentVendor?.id == vendorId) {
        _setCurrentVendor(suspendedVendor);
      }
      
      Logger.info('Vendor suspended successfully: $vendorId', tag: 'VendorViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to suspend vendor: $vendorId', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to suspend vendor');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get vendor statistics
  Future<void> getVendorStatistics() async {
    try {
      Logger.debug('Getting vendor statistics', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final stats = await _vendorRepository.getVendorStats();
      _setVendorStats(stats);
      
      Logger.debug('Vendor statistics retrieved', tag: 'VendorViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendor statistics', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load vendor statistics');
    } finally {
      _setLoading(false);
    }
  }

  // Update vendor trust score
  Future<bool> updateVendorTrustScore(String vendorId, int newScore) async {
    try {
      Logger.info('Updating trust score for vendor: $vendorId to $newScore', tag: 'VendorViewModel');
      _setLoading(true);
      _setError(null);

      final updatedVendor = await _vendorRepository.updateTrustScore(vendorId, newScore);
      
      // Update current vendor if it's the same
      if (_currentVendor?.id == vendorId) {
        _setCurrentVendor(updatedVendor);
      }
      
      Logger.info('Trust score updated successfully for vendor: $vendorId', tag: 'VendorViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update trust score for vendor: $vendorId', 
          tag: 'VendorViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update trust score');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user can become vendor
  bool canBecomeVendor(String? userRole) {
    return userRole == 'user';
  }

  // Get vendor status color
  String getVendorStatusColor(String status) {
    switch (status) {
      case 'approved':
        return 'green';
      case 'pending':
        return 'orange';
      case 'rejected':
        return 'red';
      case 'suspended':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Get vendor status display text
  String getVendorStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Verified Vendor';
      case 'pending':
        return 'Pending Verification';
      case 'rejected':
        return 'Verification Rejected';
      case 'suspended':
        return 'Suspended';
      default:
        return 'Unknown Status';
    }
  }

  void clearError() {
    _setError(null);
  }

  void clearVendors() {
    _setVendors([]);
  }

  void clearPendingVendors() {
    _setPendingVendors([]);
  }
}
