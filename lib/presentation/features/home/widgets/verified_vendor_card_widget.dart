import '../../../../core/app_export.dart';

class VerifiedVendorCardWidget extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback? onTap;

  const VerifiedVendorCardWidget({
    super.key,
    required this.vendor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vendorName = vendor.businessName;
    final scoreValue = vendor.trustScore;

    return Container(
      width: 25.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: _getTrustScoreColor(scoreValue).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Vendor Avatar
                CircleAvatar(
                  radius: 6.w,
                  backgroundColor: _getTrustScoreColor(scoreValue).withValues(alpha: 0.1),
                  child: Text(
                    vendorName.isNotEmpty ? vendorName[0].toUpperCase() : 'V',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _getTrustScoreColor(scoreValue),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Vendor Name
                Text(
                  vendorName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 1.h),
                
                // Trust Score Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrustScoreColor(scoreValue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getTrustScoreColor(scoreValue).withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 10.sp,
                        color: _getTrustScoreColor(scoreValue),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        scoreValue.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getTrustScoreColor(scoreValue),
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 80) {
      return AppTheme.successAccent;
    } else if (score >= 60) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }
}
