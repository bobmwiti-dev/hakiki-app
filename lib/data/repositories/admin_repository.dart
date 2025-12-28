import '../models/vendor_model.dart';
import '../models/user_model.dart';
import '../models/fraud_report_model.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<VendorModel>> getPendingVendors();
  Future<List<FraudReportModel>> getPendingReports();
  Future<List<UserModel>> getAllUsers();
  Future<void> approveVendor(String vendorId, String adminId);
  Future<void> rejectVendor(String vendorId, String reason);
  Future<void> suspendUser(String userId, String reason);
  Future<void> updateUserTrustScore(String userId, int score);
}

class AdminRepositoryImpl implements AdminRepository {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get collection counts from Firestore
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final vendorsSnapshot = await FirebaseFirestore.instance.collection('vendors').get();
      final fraudReportsSnapshot = await FirebaseFirestore.instance
          .collection('fraud_reports')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingVendorsSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .where('status', isEqualTo: 'pending')
          .get();

      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalVendors': vendorsSnapshot.docs.length,
        'pendingReports': fraudReportsSnapshot.docs.length,
        'pendingVendors': pendingVendorsSnapshot.docs.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      // Return default values if there's an error
      return {
        'totalUsers': 0,
        'totalVendors': 0,
        'pendingReports': 0,
        'pendingVendors': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  @override
  Future<List<VendorModel>> getPendingVendors() async {
    return await _firestoreService.getPendingVendors();
  }

  @override
  Future<List<FraudReportModel>> getPendingReports() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('fraud_reports')
          .where('status', isEqualTo: 'pending')
          .get();
      
      return query.docs
          .map((doc) => FraudReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      return query.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> approveVendor(String vendorId, String adminId) async {
    try {
      await _firestoreService.updateVendor(vendorId, {
        'status': 'approved',
        'approvedBy': adminId,
        'approvedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> rejectVendor(String vendorId, String reason) async {
    try {
      await _firestoreService.updateVendor(vendorId, {
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> suspendUser(String userId, String reason) async {
    try {
      await _firestoreService.updateUser(userId, {
        'isActive': false,
        'suspensionReason': reason,
        'suspendedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserTrustScore(String userId, int score) async {
    try {
      await _firestoreService.updateUser(userId, {
        'trustScore': score,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
