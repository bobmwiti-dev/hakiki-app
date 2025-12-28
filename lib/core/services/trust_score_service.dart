/// Trust Score Service
/// 
/// Calculates and updates trust scores for users and vendors.
/// Implements the trust score algorithm based on various factors.
library;

import '../../data/repositories/user_repository.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../data/repositories/fraud_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/activity_service.dart';
import '../utils/logger.dart';

class TrustScoreService {
  final UserRepository _userRepository = UserRepository(FirestoreService());
  final VendorRepository _vendorRepository = VendorRepository(FirestoreService());
  final FraudRepository _fraudRepository = FraudRepository(FirestoreService());
  final ActivityService _activityService = ActivityService();

  /// Calculate user trust score
  /// 
  /// Factors:
  /// - Account age (max 20 points)
  /// - Number of verifications (max 30 points)
  /// - Quality of fraud reports (max 25 points)
  /// - Community contributions (max 15 points)
  /// - Account verification status (max 10 points)
  Future<int> calculateUserTrustScore(String userId) async {
    try {
      int score = 0;

      // Get user data
      final user = await _userRepository.getUserById(userId);
      if (user == null) return 0;

      // 1. Account age (0-20 points)
      final accountAge = DateTime.now().difference(user.createdAt).inDays;
      final ageScore = (accountAge / 365 * 20).clamp(0, 20).toInt();
      score += ageScore;

      // 2. Number of verifications (0-30 points)
      final activities = await _activityService.getRecentActivities(userId: userId, limit: 1000);
      final verificationCount = activities.where((a) => a.type == 'verification').length;
      final verificationScore = (verificationCount * 2).clamp(0, 30);
      score += verificationScore;

      // 3. Quality of fraud reports (0-25 points)
      final reports = await _fraudRepository.getReportsByReporter(userId, limit: 100);
      final resolvedReports = reports.where((r) => r.status == 'resolved').length;
      final reportScore = (resolvedReports * 5).clamp(0, 25);
      score += reportScore;

      // 4. Community contributions (0-15 points)
      // Based on helpful reports and verifications
      final contributionScore = ((verificationCount + resolvedReports) * 0.5).clamp(0, 15).toInt();
      score += contributionScore;

      // 5. Account verification status (0-10 points)
      if (user.isVerified) {
        score += 10;
      }

      final finalScore = score.clamp(0, 100);
      Logger.info('Calculated trust score for user $userId: $finalScore', tag: 'TrustScoreService');
      return finalScore;
    } catch (e) {
      Logger.error('Failed to calculate user trust score', tag: 'TrustScoreService', error: e);
      return 0;
    }
  }

  /// Calculate vendor trust score
  /// 
  /// Factors:
  /// - Verification status (max 30 points)
  /// - Number of products (max 20 points)
  /// - Number of verifications (max 25 points)
  /// - Fraud reports against vendor (max 15 points, negative)
  /// - Vendor age (max 10 points)
  Future<int> calculateVendorTrustScore(String vendorId) async {
    try {
      int score = 0;

      // Get vendor data
      final vendor = await _vendorRepository.getVendorById(vendorId);
      if (vendor == null) return 0;

      // 1. Verification status (0-30 points)
      if (vendor.verificationStatus == 'approved') {
        score += 30;
      } else if (vendor.verificationStatus == 'pending') {
        score += 10;
      }

      // 2. Number of products (0-20 points)
      final productScore = (vendor.totalProducts * 2).clamp(0, 20);
      score += productScore;

      // 3. Number of verifications (0-25 points)
      // This would require querying product verifications
      // For now, use a placeholder
      const verificationScore = 15; // Placeholder
      score += verificationScore;

      // 4. Fraud reports (negative, max -15 points)
      final reports = await _fraudRepository.getReportsByVendor(vendorId, limit: 100);
      final reportPenalty = (reports.length * 3).clamp(0, 15);
      score -= reportPenalty;

      // 5. Vendor age (0-10 points)
      final vendorAge = DateTime.now().difference(vendor.createdAt).inDays;
      final ageScore = (vendorAge / 365 * 10).clamp(0, 10).toInt();
      score += ageScore;

      final finalScore = score.clamp(0, 100);
      Logger.info('Calculated trust score for vendor $vendorId: $finalScore', tag: 'TrustScoreService');
      return finalScore;
    } catch (e) {
      Logger.error('Failed to calculate vendor trust score', tag: 'TrustScoreService', error: e);
      return 0;
    }
  }

  /// Update user trust score
  Future<void> updateUserTrustScore(String userId) async {
    try {
      final newScore = await calculateUserTrustScore(userId);
      final user = await _userRepository.getUserById(userId);
      
      if (user != null && user.trustScore != newScore) {
        final oldScore = user.trustScore;
        await _userRepository.updateTrustScore(userId, newScore);
        
        // Create activity for trust score change
        await _activityService.createTrustScoreActivity(
          userId: userId,
          oldScore: oldScore,
          newScore: newScore,
          reason: 'Automatic recalculation',
        );
      }
    } catch (e) {
      Logger.error('Failed to update user trust score', tag: 'TrustScoreService', error: e);
    }
  }

  /// Update vendor trust score
  Future<void> updateVendorTrustScore(String vendorId) async {
    try {
      final newScore = await calculateVendorTrustScore(vendorId);
      await _vendorRepository.updateTrustScore(vendorId, newScore);
    } catch (e) {
      Logger.error('Failed to update vendor trust score', tag: 'TrustScoreService', error: e);
    }
  }
}


