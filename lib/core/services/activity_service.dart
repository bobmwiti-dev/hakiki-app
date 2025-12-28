/// Activity Service
/// 
/// Manages user activity tracking and retrieval.
/// Creates activity records for verifications, reports, and trust score changes.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/fraud_report_model.dart';
import '../../data/models/product_model.dart';
import '../utils/logger.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'activities';

  /// Create activity for product verification
  Future<void> createVerificationActivity({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      final activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: 'verification',
        title: 'Product Verified',
        description: 'Verified ${product.name}',
        productId: product.id,
        metadata: {
          'productName': product.name,
          'vendorId': product.vendorId,
          'isVerified': product.isVerified,
        },
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(activity.id)
          .set(activity.toFirestore());

      Logger.info('Verification activity created', tag: 'ActivityService');
    } catch (e) {
      Logger.error('Failed to create verification activity', tag: 'ActivityService', error: e);
    }
  }

  /// Create activity for fraud report
  Future<void> createReportActivity({
    required String userId,
    required FraudReportModel report,
  }) async {
    try {
      final activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: 'report',
        title: 'Fraud Report Submitted',
        description: report.title,
        reportId: report.id,
        productId: report.productId,
        vendorId: report.vendorId,
        metadata: {
          'reportType': report.type,
          'status': report.status,
        },
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(activity.id)
          .set(activity.toFirestore());

      Logger.info('Report activity created', tag: 'ActivityService');
    } catch (e) {
      Logger.error('Failed to create report activity', tag: 'ActivityService', error: e);
    }
  }

  /// Create activity for trust score change
  Future<void> createTrustScoreActivity({
    required String userId,
    required int oldScore,
    required int newScore,
    required String reason,
  }) async {
    try {
      final activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: 'trust_score_change',
        title: 'Trust Score Updated',
        description: 'Score changed from $oldScore to $newScore',
        metadata: {
          'oldScore': oldScore,
          'newScore': newScore,
          'change': newScore - oldScore,
          'reason': reason,
        },
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(activity.id)
          .set(activity.toFirestore());

      Logger.info('Trust score activity created', tag: 'ActivityService');
    } catch (e) {
      Logger.error('Failed to create trust score activity', tag: 'ActivityService', error: e);
    }
  }

  /// Get recent activities for a user
  Future<List<ActivityModel>> getRecentActivities({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.error('Failed to get recent activities', tag: 'ActivityService', error: e);
      return [];
    }
  }

  /// Stream recent activities for a user
  Stream<List<ActivityModel>> streamRecentActivities({
    required String userId,
    int limit = 10,
  }) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      Logger.error('Failed to stream activities', tag: 'ActivityService', error: e);
      return Stream.value([]);
    }
  }
}


