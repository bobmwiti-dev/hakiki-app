/// Vendor Card Widget
/// 
/// Displays vendor information in a card format.
/// Shows vendor status, trust score, and basic information.
library;

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../data/models/vendor_model.dart';

class VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback? onTap;

  const VendorCard({
    super.key,
    required this.vendor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.borderRadiusMedium,
        child: Padding(
          padding: AppStyles.paddingMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vendor name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vendor.businessName,
                      style: AppStyles.heading4,
                    ),
                  ),
                  _buildStatusChip(vendor.verificationStatus),
                ],
              ),
              const SizedBox(height: 8),
              // Business type
              if (vendor.businessType.isNotEmpty)
                Text(
                  vendor.businessType,
                  style: AppStyles.bodySmall,
                ),
              const SizedBox(height: 12),
              // Trust score
              Row(
                children: [
                  const Icon(Icons.verified, size: 16, color: AppColors.trustHigh),
                  const SizedBox(width: 4),
                  Text(
                    'Trust Score: ${vendor.trustScore}',
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Stats
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.inventory,
                    label: 'Products',
                    value: vendor.totalProducts.toString(),
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    icon: Icons.report,
                    label: 'Reports',
                    value: vendor.totalReports.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'verified':
        color = AppColors.vendorVerified;
        label = 'Verified';
        break;
      case 'pending':
        color = AppColors.vendorPending;
        label = 'Pending';
        break;
      case 'rejected':
        color = AppColors.vendorRejected;
        label = 'Rejected';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: AppStyles.bodySmall,
        ),
      ],
    );
  }
}

