import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart'; // Package not available, using mock implementation
import 'package:sizer/sizer.dart';


class ActionButtonsWidget extends StatelessWidget {
  final String productName;
  final String verificationStatus;
  final VoidCallback? onReportFake;
  final VoidCallback? onAddToWatchlist;

  const ActionButtonsWidget({
    super.key,
    required this.productName,
    required this.verificationStatus,
    this.onReportFake,
    this.onAddToWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              if (verificationStatus.toLowerCase() == 'suspicious' ||
                  verificationStatus.toLowerCase() == 'unknown') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mock share functionality - replace with actual share implementation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sharing: $productName is $verificationStatus'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.report,
                      color: Colors.white,
                      size: 4.w,
                    ),
                    label: Text(
                      'Report as Fake',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddToWatchlist ?? () => _addToWatchlist(context),
                  icon: Icon(
                    Icons.bookmark_border,
                    color: Theme.of(context).primaryColor,
                    size: 4.w,
                  ),
                  label: Text(
                    'Add to Watchlist',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _shareVerificationResult(context),
              icon: Icon(
                Icons.share,
                color: Theme.of(context).primaryColor,
                size: 4.w,
              ),
              label: Text(
                'Share Verification',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 2.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withAlpha(77),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withAlpha(77),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.green,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help Others',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Your verification helps build a safer marketplace for everyone',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _addToWatchlist(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName added to watchlist'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _shareVerificationResult(BuildContext context) {
    // Mock share functionality - replace with actual share implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing verification result for $productName'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
