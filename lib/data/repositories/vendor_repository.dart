import '../../core/utils/logger.dart';
import '../../core/services/firestore_service.dart';
import '../models/vendor_model.dart';

class VendorRepository {
  final FirestoreService _firestoreService;

  VendorRepository(this._firestoreService);

  // Create a new vendor
  Future<VendorModel> createVendor(VendorModel vendor) async {
    try {
      Logger.info('Creating vendor: ${vendor.businessName}', tag: 'VendorRepository');
      
      await _firestoreService.createVendor(vendor);
      final createdVendor = vendor;
      
      Logger.info('Vendor created successfully: ${createdVendor.id}', tag: 'VendorRepository');
      return createdVendor;
    } catch (e, stackTrace) {
      Logger.error('Failed to create vendor: ${vendor.businessName}', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get vendor by ID
  Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      Logger.debug('Getting vendor by ID: $vendorId', tag: 'VendorRepository');
      
      final vendor = await _firestoreService.getVendor(vendorId);
      if (vendor != null) {
        Logger.debug('Vendor found: ${vendor.businessName}', tag: 'VendorRepository');
        return vendor;
      }
      
      Logger.debug('Vendor not found: $vendorId', tag: 'VendorRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendor by ID: $vendorId', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get vendor by user ID
  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      Logger.debug('Getting vendor by user ID: $userId', tag: 'VendorRepository');
      
      final vendor = await _firestoreService.getVendorByUserId(userId);
      
      if (vendor != null) {
        Logger.debug('Vendor found by user ID: ${vendor.id}', tag: 'VendorRepository');
        return vendor;
      }
      
      Logger.debug('Vendor not found by user ID: $userId', tag: 'VendorRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendor by user ID: $userId', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update vendor
  Future<VendorModel> updateVendor(VendorModel vendor) async {
    try {
      Logger.info('Updating vendor: ${vendor.id}', tag: 'VendorRepository');
      
      final updatedVendor = vendor.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateVendor(vendor.id, updatedVendor.toJson());
      
      Logger.info('Vendor updated successfully: ${vendor.id}', tag: 'VendorRepository');
      return updatedVendor;
    } catch (e, stackTrace) {
      Logger.error('Failed to update vendor: ${vendor.id}', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get vendors by status
  Future<List<VendorModel>> getVendorsByStatus(String status, {int? limit}) async {
    try {
      Logger.debug('Getting vendors by status: $status', tag: 'VendorRepository');
      
      final vendors = await _firestoreService.getVendorsByStatus(status, limit: limit);
      
      Logger.debug('Found ${vendors.length} vendors with status: $status', tag: 'VendorRepository');
      return vendors;
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendors by status: $status', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Approve vendor
  Future<VendorModel> approveVendor(String vendorId, String approvedBy) async {
    try {
      Logger.info('Approving vendor: $vendorId', tag: 'VendorRepository');
      
      final vendor = await getVendorById(vendorId);
      if (vendor == null) {
        throw Exception('Vendor not found: $vendorId');
      }
      
      final approvedVendor = vendor.copyWith(
        verificationStatus: 'approved',
        approvedAt: DateTime.now(),
        approvedBy: approvedBy,
      );
      
      await _firestoreService.updateVendor(vendor.id, approvedVendor.toJson());
      
      Logger.info('Vendor approved successfully: $vendorId', tag: 'VendorRepository');
      return approvedVendor;
    } catch (e, stackTrace) {
      Logger.error('Failed to approve vendor: $vendorId', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Reject vendor
  Future<VendorModel> rejectVendor(String vendorId, String rejectionReason) async {
    try {
      Logger.info('Rejecting vendor: $vendorId', tag: 'VendorRepository');
      
      final vendor = await getVendorById(vendorId);
      if (vendor == null) {
        throw Exception('Vendor not found: $vendorId');
      }
      
      final rejectedVendor = vendor.copyWith(
        verificationStatus: 'rejected',
        rejectionReason: rejectionReason,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateVendor(vendorId, rejectedVendor.toJson());
      
      Logger.info('Vendor rejected successfully: $vendorId', tag: 'VendorRepository');
      return rejectedVendor;
    } catch (e, stackTrace) {
      Logger.error('Failed to reject vendor: $vendorId', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Search vendors
  Future<List<VendorModel>> searchVendors(String query, {int? limit}) async {
    try {
      Logger.debug('Searching vendors with query: $query', tag: 'VendorRepository');
      
      final vendors = await _firestoreService.searchVendors(query, limit: limit);
      
      Logger.debug('Found ${vendors.length} vendors matching query: $query', tag: 'VendorRepository');
      return vendors;
    } catch (e, stackTrace) {
      Logger.error('Failed to search vendors with query: $query', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get top vendors by trust score
  Future<List<VendorModel>> getTopVendors({int limit = 10}) async {
    try {
      Logger.debug('Getting top vendors by trust score', tag: 'VendorRepository');
      
      // getTopVendors method not available in FirestoreService
      // TODO: Implement getTopVendors in FirestoreService if needed
      Logger.debug('getTopVendors not implemented in FirestoreService', tag: 'VendorRepository');
      final vendors = <VendorModel>[];
      
      Logger.debug('Found ${vendors.length} top vendors', tag: 'VendorRepository');
      return vendors;
    } catch (e, stackTrace) {
      Logger.error('Failed to get top vendors', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update vendor trust score
  Future<VendorModel> updateTrustScore(String vendorId, int newScore) async {
    try {
      Logger.info('Updating trust score for vendor: $vendorId to $newScore', tag: 'VendorRepository');
      
      final vendor = await getVendorById(vendorId);
      if (vendor == null) {
        throw Exception('Vendor not found: $vendorId');
      }
      
      final updatedVendor = vendor.copyWith(
        trustScore: newScore,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateVendor(vendorId, {'isActive': true, 'updatedAt': DateTime.now().toIso8601String()});
      
      Logger.info('Trust score updated successfully for vendor: $vendorId', tag: 'VendorRepository');
      return updatedVendor;
    } catch (e, stackTrace) {
      Logger.error('Failed to update trust score for vendor: $vendorId', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get vendor statistics
  Future<Map<String, dynamic>> getVendorStats() async {
    try {
      Logger.debug('Getting vendor statistics', tag: 'VendorRepository');
      
      // Get all vendors and pending vendors using available FirestoreService methods
      final allVendors = await _firestoreService.getVendors(limit: 1000); // Get more for accurate count
      final pendingVendorsList = await _firestoreService.getPendingVendors();
      
      final totalVendors = allVendors.length;
      final pendingVendors = pendingVendorsList.length;
      
      // Count vendors by status
      final approvedVendors = allVendors.where((v) => v.verificationStatus == 'approved').length;
      final activeVendors = allVendors.where((v) => v.verificationStatus == 'approved').length; // Consider approved as active
      final suspendedVendors = allVendors.where((v) => v.verificationStatus == 'suspended').length;
      
      final stats = {
        'totalVendors': totalVendors,
        'activeVendors': activeVendors,
        'approvedVendors': approvedVendors,
        'pendingVendors': pendingVendors,
        'suspendedVendors': suspendedVendors,
      };
      
      Logger.debug('Vendor statistics retrieved: $stats', tag: 'VendorRepository');
      return stats;
    } catch (e, stackTrace) {
      Logger.error('Failed to get vendor statistics', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Suspend vendor
  Future<VendorModel> suspendVendor(String vendorId, String reason) async {
    try {
      Logger.info('Suspending vendor: $vendorId', tag: 'VendorRepository');
      
      final vendor = await getVendorById(vendorId);
      if (vendor == null) {
        throw Exception('Vendor not found: $vendorId');
      }
      
      final suspendedVendor = vendor.copyWith(
        verificationStatus: 'suspended',
        rejectionReason: reason,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateVendor(vendorId, suspendedVendor.toJson());
      
      Logger.info('Vendor suspended successfully: $vendorId', tag: 'VendorRepository');
      return suspendedVendor;
    } catch (e, stackTrace) {
      Logger.error('Failed to suspend vendor: $vendorId', 
          tag: 'VendorRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
