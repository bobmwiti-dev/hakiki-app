import 'package:flutter/material.dart';

class VerificationUtils {
  /// Get color based on verification status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'authentic':
        return Colors.green;
      case 'suspicious':
        return Colors.orange;
      case 'unknown':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get icon based on verification status
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'authentic':
        return Icons.verified_user;
      case 'suspicious':
        return Icons.warning;
      case 'unknown':
        return Icons.help_outline;
      default:
        return Icons.help_outline;
    }
  }

  /// Get status text
  static String getStatusText(String status) {
    switch (status) {
      case 'authentic':
        return 'Authentic';
      case 'suspicious':
        return 'Suspicious';
      case 'unknown':
        return 'Unknown';
      default:
        return 'Unknown';
    }
  }

  /// Get risk severity color
  static Color getRiskSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get risk severity text
  static String getRiskSeverityText(String severity) {
    switch (severity) {
      case 'low':
        return 'Low Risk';
      case 'medium':
        return 'Medium Risk';
      case 'high':
        return 'High Risk';
      default:
        return 'Unknown Risk';
    }
  }

  /// Get verification method icon
  static IconData getVerificationMethodIcon(String method) {
    switch (method) {
      case 'qrCode':
        return Icons.qr_code;
      case 'barcode':
        return Icons.barcode_reader;
      case 'nfc':
        return Icons.nfc;
      case 'manual':
        return Icons.edit;
      case 'image':
        return Icons.camera_alt;
      default:
        return Icons.help_outline;
    }
  }

  /// Get verification method text
  static String getVerificationMethodText(String method) {
    switch (method) {
      case 'qrCode':
        return 'QR Code';
      case 'barcode':
        return 'Barcode';
      case 'nfc':
        return 'NFC';
      case 'manual':
        return 'Manual';
      case 'image':
        return 'Image';
      default:
        return 'Unknown';
    }
  }

  /// Get report type color
  static Color getReportTypeColor(String type) {
    switch (type) {
      case 'authentic':
        return Colors.green;
      case 'fake':
        return Colors.red;
      case 'suspicious':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Get report type text
  static String getReportTypeText(String type) {
    switch (type) {
      case 'authentic':
        return 'Authentic';
      case 'fake':
        return 'Fake';
      case 'suspicious':
        return 'Suspicious';
      default:
        return 'Unknown';
    }
  }

  /// Calculate overall risk level based on indicators
  static String calculateOverallRisk(List<Map<String, dynamic>> indicators) {
    if (indicators.isEmpty) return 'low';

    final highRiskCount = indicators.where((i) => i['severity'] == 'high').length;
    final mediumRiskCount = indicators.where((i) => i['severity'] == 'medium').length;

    if (highRiskCount > 0) return 'high';
    if (mediumRiskCount > 0) return 'medium';
    return 'low';
  }

  /// Format trust score as percentage
  static String formatTrustScore(double score) {
    return '${(score * 100).toInt()}%';
  }

  /// Get trust score color
  static Color getTrustScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get recommendation based on verification status and risk level
  static String getRecommendation(String status, String riskLevel) {
    if (status == 'authentic' && riskLevel == 'low') {
      return 'This product appears to be authentic. Safe to purchase.';
    } else if (status == 'authentic' && riskLevel == 'medium') {
      return 'Product is likely authentic but has some risk indicators. Proceed with caution.';
    } else if (status == 'suspicious') {
      return 'This product shows suspicious characteristics. We recommend avoiding this purchase.';
    } else {
      return 'Unable to verify this product. Consider purchasing from authorized retailers.';
    }
  }

  /// Check if product should be flagged for review
  static bool shouldFlagForReview(Map<String, dynamic> verification) {
    final riskIndicators = verification['riskIndicators'] as List<dynamic>? ?? [];
    final highRiskCount = riskIndicators
        .where((risk) => risk['severity'] == 'high')
        .length;
    
    return verification['verificationStatus'] == 'suspicious' ||
           highRiskCount >= 2 ||
           (verification['trustScore'] as double? ?? 1.0) < 0.3;
  }

  /// Generate share text for verification result
  static String generateShareText(Map<String, dynamic> verification) {
    final status = getStatusText(verification['verificationStatus'] ?? 'unknown');
    final trustScore = formatTrustScore(verification['trustScore'] ?? 0.0);
    
    return '''
🛡️ Product Verification Result

Product: ${verification['productName'] ?? 'Unknown Product'}
Status: $status
Trust Score: $trustScore
Verified via Hakiki Anti-Fraud App

Help build a safer marketplace by verifying products before purchase!

Download Hakiki: [App Store Link]
    ''';
  }
}
