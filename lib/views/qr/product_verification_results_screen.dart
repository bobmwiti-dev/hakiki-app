/// Product Verification Results Screen
///
/// Displays the results of product verification.
/// Shows product details and verification status.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/activity_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/vendor_model.dart';

class ProductVerificationResultsScreen extends StatefulWidget {
  final dynamic data;
  final String type;

  const ProductVerificationResultsScreen({
    super.key,
    this.data,
    this.type = 'product',
  });

  @override
  State<ProductVerificationResultsScreen> createState() =>
      _ProductVerificationResultsScreenState();
}

class _ProductVerificationResultsScreenState
    extends State<ProductVerificationResultsScreen> {
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _createVerificationActivity();
  }

  Future<void> _createVerificationActivity() async {
    final user = FirebaseAuthService().currentUser;
    if (user == null || widget.data == null) return;

    try {
      if (widget.type == 'product' && widget.data is ProductModel) {
        await _activityService.createVerificationActivity(
          userId: user.uid,
          product: widget.data as ProductModel,
        );
      }
      // For vendors, we could create a different type of activity if needed
    } catch (e) {
      // Activity creation failure shouldn't block the UI
      debugPrint('Failed to create verification activity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVerified =
        widget.data != null &&
        ((widget.data is ProductModel &&
                (widget.data as ProductModel).isVerified) ||
            (widget.data is VendorModel));
    final String name = _getName();
    final String details = _getDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'product'
              ? AppStrings.productDetails
              : AppStrings.vendorInfo,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification status
            Card(
              color: isVerified ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.cancel,
                      color: isVerified ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVerified
                                ? (widget.type == 'product'
                                    ? AppStrings.productVerified
                                    : 'Vendor Verified')
                                : (widget.type == 'product'
                                    ? AppStrings.productSuspicious
                                    : 'Vendor Unverified'),
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: isVerified ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Details section
            Text(
              widget.type == 'product'
                  ? AppStrings.productDetails
                  : AppStrings.vendorInfo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(details),
              ),
            ),
            const SizedBox(height: 32),
            // Actions
            if (!isVerified)
              ElevatedButton.icon(
                onPressed: () {
                  final args =
                      widget.type == 'product'
                          ? {'productId': (widget.data as ProductModel?)?.id}
                          : {'vendorId': (widget.data as VendorModel?)?.id};
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.fraudReport, arguments: args);
                },
                icon: const Icon(Icons.report),
                label: const Text(AppStrings.reportThisProduct),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getName() {
    if (widget.data == null) return 'Unknown';

    if (widget.type == 'product') {
      return (widget.data as ProductModel).name;
    } else {
      return (widget.data as VendorModel).businessName;
    }
  }

  String _getDetails() {
    if (widget.data == null) return 'No details available';

    if (widget.type == 'product') {
      final product = widget.data as ProductModel;
      return '''
Name: ${product.name}
Category: ${product.category}
Price: ${product.price}
Description: ${product.description}
Vendor: ${product.vendorId}
Status: ${product.isVerified ? 'Verified' : 'Unverified'}
      '''.trim();
    } else {
      final vendor = widget.data as VendorModel;
      return '''
Business Name: ${vendor.businessName}
Email: ${vendor.businessEmail}
Phone: ${vendor.businessPhone ?? 'Not provided'}
Address: ${vendor.businessAddress}
Status: ${vendor.verificationStatus}
Trust Score: ${vendor.trustScore}
      '''.trim();
    }
  }
}
