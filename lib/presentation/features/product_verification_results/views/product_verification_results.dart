import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../shared/routes/routes/app_routes.dart';
import '../widgets/action_buttons_widget.dart';
import '../widgets/community_insights_widget.dart';
import '../widgets/product_details_widget.dart';
import '../widgets/risk_assessment_widget.dart';
import '../widgets/verification_history_widget.dart';
import '../widgets/verification_status_widget.dart';

class ProductVerificationResults extends StatefulWidget {
  const ProductVerificationResults({super.key});

  @override
  State<ProductVerificationResults> createState() =>
      _ProductVerificationResultsState();
}

class _ProductVerificationResultsState
    extends State<ProductVerificationResults> {
  bool _isLoading = false;
  bool _isOffline = false;
  String _errorMessage = '';

  // Mock data for demonstration
  final Map<String, dynamic> _mockProduct = {
    "id": "PRD001",
    "name": "iPhone 15 Pro Max",
    "brand": "Apple",
    "model": "A3108",
    "category": "Electronics",
    "sku": "IPHONE15PM-256GB-NT",
    "priceRange": "\$1,199 - \$1,399",
    "image":
        "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500&h=500&fit=crop",
    "verificationStatus": "authentic",
    "confidenceScore": 0.95,
  };

  final List<Map<String, dynamic>> _mockVerificationHistory = [
    {
      "id": 1,
      "verifierName": "Sarah Johnson",
      "trustScore": 0.92,
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "method": "qr",
      "location": "New York, NY",
    },
    {
      "id": 2,
      "verifierName": "Michael Chen",
      "trustScore": 0.88,
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "method": "barcode",
      "location": "San Francisco, CA",
    },
    {
      "id": 3,
      "verifierName": "Emma Rodriguez",
      "trustScore": 0.95,
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "method": "qr",
      "location": "Los Angeles, CA",
    },
    {
      "id": 4,
      "verifierName": "David Kim",
      "trustScore": 0.85,
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "method": "barcode",
      "location": "Chicago, IL",
    },
    {
      "id": 5,
      "verifierName": "Lisa Thompson",
      "trustScore": 0.90,
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
      "method": "qr",
      "location": "Miami, FL",
    },
    {
      "id": 6,
      "verifierName": "James Wilson",
      "trustScore": 0.87,
      "timestamp": DateTime.now().subtract(const Duration(days: 7)),
      "method": "barcode",
      "location": "Seattle, WA",
    },
  ];

  final List<Map<String, dynamic>> _mockRiskIndicators = [
    {
      "id": 1,
      "title": "Price Discrepancy Detected",
      "severity": "medium",
      "description":
          "The listed price is 15% below the average market price for this product. This could indicate a potential counterfeit or damaged item.",
      "recommendation":
          "Verify the seller's reputation and ask for additional product photos before purchasing.",
    },
    {
      "id": 2,
      "title": "Seller Location Mismatch",
      "severity": "low",
      "description":
          "The seller's registered location doesn't match the product's shipping origin. This is common but worth noting.",
      "recommendation":
          "Confirm shipping details and estimated delivery time with the seller.",
    },
  ];

  final List<Map<String, dynamic>> _mockSimilarReports = [
    {
      "id": 1,
      "productName": "iPhone 15 Pro",
      "type": "authentic",
      "count": 45,
      "similarity": 95,
    },
    {
      "id": 2,
      "productName": "iPhone 15 Pro Max (Fake)",
      "type": "fake",
      "count": 12,
      "similarity": 78,
    },
    {
      "id": 3,
      "productName": "iPhone 15 Plus",
      "type": "authentic",
      "count": 32,
      "similarity": 85,
    },
    {
      "id": 4,
      "productName": "iPhone 14 Pro Max",
      "type": "suspicious",
      "count": 8,
      "similarity": 72,
    },
  ];

  final Map<String, dynamic> _mockFraudPatterns = {
    "priceManipulation": 23,
    "fakeReviews": 18,
    "locationMismatches": 12,
  };

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadVerificationData();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  Future<void> _loadVerificationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate potential errors
      if (DateTime.now().millisecond % 10 == 0) {
        throw Exception('Network timeout');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load verification data. Please try again.';
      });
    }
  }

  Future<void> _refreshData() async {
    await _checkConnectivity();
    await _loadVerificationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Verification Results',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareResults(context),
            icon: Icon(
              Icons.share,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
              size: 5.w,
            ),
          ),
          SizedBox(width: 2.w),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (_isOffline) _buildOfflineBanner(),

                        // Large Product Image with Verification Badge
                        _buildProductImageSection(),

                        // Verification Status
                        VerificationStatusWidget(
                          status: _mockProduct['verificationStatus'] as String,
                          confidenceScore:
                              (_mockProduct['confidenceScore'] as num)
                                  .toDouble(),
                          productName: _mockProduct['name'] as String,
                          brand: _mockProduct['brand'] as String,
                        ),

                        // Product Details
                        ProductDetailsWidget(product: _mockProduct),

                        // Verification History
                        VerificationHistoryWidget(
                          verificationHistory: _mockVerificationHistory,
                        ),

                        // Risk Assessment
                        RiskAssessmentWidget(
                          riskIndicators: _mockRiskIndicators,
                        ),

                        // Action Buttons
                        ActionButtonsWidget(
                          productName: _mockProduct['name'] as String,
                          verificationStatus:
                              _mockProduct['verificationStatus'] as String,
                          onReportFake: () => _navigateToReportScreen(),
                          onAddToWatchlist: () => _addToWatchlist(),
                        ),

                        // Community Insights
                        CommunityInsightsWidget(
                          similarReports: _mockSimilarReports,
                          fraudPatterns: _mockFraudPatterns,
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Analyzing product verification...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 12.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'Verification Failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      color: Colors.orange.withAlpha(25),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Showing cached results. Connect to internet for latest data.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          TextButton(
            onPressed: _refreshData,
            child: Text(
              'Verify Online',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImageSection() {
    final status = _mockProduct['verificationStatus'] as String;
    Color badgeColor;
    IconData badgeIcon;

    switch (status.toLowerCase()) {
      case 'authentic':
        badgeColor = Colors.green;
        badgeIcon = Icons.verified;
        break;
      case 'suspicious':
        badgeColor = Colors.red;
        badgeIcon = Icons.dangerous;
        break;
      case 'unknown':
      default:
        badgeColor = Colors.orange;
        badgeIcon = Icons.help;
        break;
    }

    return Container(
      width: double.infinity,
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _mockProduct['image'] as String,
              width: double.infinity,
              height: 40.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 40.h,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 3.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                badgeIcon,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(179),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                _mockProduct['name'] as String,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context) {
    // This will be handled by ActionButtonsWidget
  }

  void _navigateToReportScreen() {
    Navigator.pushNamed(context, AppRoutes.fraudReportScreen);
  }

  void _addToWatchlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_mockProduct['name']} added to watchlist'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
