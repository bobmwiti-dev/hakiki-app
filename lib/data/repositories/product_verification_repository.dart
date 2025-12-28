import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_verification_model.dart';

abstract class ProductVerificationRepository {
  Future<ProductVerificationModel> verifyProduct(String productId);
  Future<List<ProductVerificationModel>> getVerificationHistory();
  Future<void> reportFakeProduct(String productId, String reason);
  Future<void> addToWatchlist(String productId);
}

class ProductVerificationRepositoryImpl implements ProductVerificationRepository {
  final http.Client _httpClient;
  final String _baseUrl;

  ProductVerificationRepositoryImpl({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://api.hakiki.com/v1';

  @override
  Future<ProductVerificationModel> verifyProduct(String productId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/products/$productId/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductVerificationModel.fromJson(data);
      } else {
        throw Exception('Failed to verify product: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockProductVerification(productId);
    }
  }

  @override
  Future<List<ProductVerificationModel>> getVerificationHistory() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/verifications/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => ProductVerificationModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get verification history: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockVerificationHistory();
    }
  }

  @override
  Future<void> reportFakeProduct(String productId, String reason) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/products/$productId/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
        body: json.encode({
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report fake product: ${response.statusCode}');
      }
    } catch (e) {
      // Mock success for development
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<void> addToWatchlist(String productId) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/watchlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with actual token
        },
        body: json.encode({
          'productId': productId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add to watchlist: ${response.statusCode}');
      }
    } catch (e) {
      // Mock success for development
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Mock data methods for development
  ProductVerificationModel _getMockProductVerification(String productId) {
    return ProductVerificationModel(
      id: productId,
      name: "iPhone 15 Pro Max",
      brand: "Apple",
      model: "A3108",
      category: "Electronics",
      sku: "IPHONE15PM-256GB-NT",
      priceRange: "\$1,199 - \$1,399",
      imageUrl: "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500&h=500&fit=crop",
      verificationStatus: VerificationStatus.authentic,
      confidenceScore: 0.95,
      verificationHistory: _getMockVerificationHistoryList(),
      riskIndicators: _getMockRiskIndicators(),
      similarReports: _getMockSimilarReports(),
      fraudPatterns: _getMockFraudPatterns(),
    );
  }

  List<ProductVerificationModel> _getMockVerificationHistory() {
    return [
      _getMockProductVerification("PRD001"),
      _getMockProductVerification("PRD002"),
      _getMockProductVerification("PRD003"),
    ];
  }

  List<VerificationHistoryModel> _getMockVerificationHistoryList() {
    return [
      VerificationHistoryModel(
        id: 1,
        verifierName: "Sarah Johnson",
        trustScore: 0.92,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        method: VerificationMethod.qr,
        location: "New York, NY",
      ),
      VerificationHistoryModel(
        id: 2,
        verifierName: "Michael Chen",
        trustScore: 0.88,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        method: VerificationMethod.barcode,
        location: "San Francisco, CA",
      ),
      VerificationHistoryModel(
        id: 3,
        verifierName: "Emma Rodriguez",
        trustScore: 0.95,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        method: VerificationMethod.qr,
        location: "Los Angeles, CA",
      ),
    ];
  }

  List<RiskIndicatorModel> _getMockRiskIndicators() {
    return [
      RiskIndicatorModel(
        id: 1,
        title: "Price Discrepancy Detected",
        severity: RiskSeverity.medium,
        description: "The listed price is 15% below the average market price for this product. This could indicate a potential counterfeit or damaged item.",
        recommendation: "Verify the seller's reputation and ask for additional product photos before purchasing.",
      ),
      RiskIndicatorModel(
        id: 2,
        title: "Seller Location Mismatch",
        severity: RiskSeverity.low,
        description: "The seller's registered location doesn't match the product's shipping origin. This is common but worth noting.",
        recommendation: "Confirm shipping details and estimated delivery time with the seller.",
      ),
    ];
  }

  List<SimilarReportModel> _getMockSimilarReports() {
    return [
      SimilarReportModel(
        id: 1,
        productName: "iPhone 15 Pro",
        type: ReportType.authentic,
        count: 45,
        similarity: 95,
      ),
      SimilarReportModel(
        id: 2,
        productName: "iPhone 15 Pro Max (Fake)",
        type: ReportType.fake,
        count: 12,
        similarity: 78,
      ),
      SimilarReportModel(
        id: 3,
        productName: "iPhone 15 Plus",
        type: ReportType.authentic,
        count: 32,
        similarity: 85,
      ),
    ];
  }

  FraudPatternsModel _getMockFraudPatterns() {
    return FraudPatternsModel(
      priceManipulation: 23,
      fakeReviews: 18,
      locationMismatches: 12,
    );
  }
}
