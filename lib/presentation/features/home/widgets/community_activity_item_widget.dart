import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CommunityActivityItemWidget extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onHide;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  const CommunityActivityItemWidget({
    super.key,
    required this.activity,
    this.onHide,
    this.onReport,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final String activityType = activity["type"] ?? "verification";
    final String description = activity["description"] ?? "";
    final String timestamp = activity["timestamp"] ?? "";
    final int engagementCount = activity["engagementCount"] ?? 0;
    final String location = activity["location"] ?? "";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color:
                        _getActivityColor(activityType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(activityType),
                    color: _getActivityColor(activityType),
                    size: 4.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getActivityTitle(activityType),
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              location,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: Theme.of(context).primaryColor,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        "$engagementCount",
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(0.25.h),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: Icon(
                _getActivityIcon(activity["type"] ?? "verification"),
                color: _getActivityColor(activity["type"] ?? "verification"),
                size: 5.w,
              ),
              title: Text(
                "Hide Activity",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                onHide?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.report,
                color: Colors.orange,
                size: 24,
              ),
              title: Text(
                "Report Spam",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.orange,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onReport?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.block,
                color: Colors.red,
                size: 24,
              ),
              title: Text(
                "Block User",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onBlock?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor([String? type]) {
    final activityType = type ?? activity["type"];
    switch (activityType) {
      case 'verification':
        return Colors.blue;
      case 'fraud_report':
        return Colors.red;
      case 'community_help':
        return Colors.green;
      default:
        return Colors.grey[600] ?? Colors.grey;
    }
  }

  IconData _getActivityIcon([String? type]) {
    final activityType = type ?? activity["type"];
    switch (activityType) {
      case 'verification':
        return Icons.verified_user;
      case 'fraud_report':
        return Icons.report_problem;
      case 'community_help':
        return Icons.help;
      default:
        return Icons.timeline;
    }
  }

  String _getActivityTitle(String type) {
    switch (type.toLowerCase()) {
      case 'verification':
        return 'Product Verified';
      case 'fraud_report':
        return 'Fraud Reported';
      case 'community_help':
        return 'Community Help';
      default:
        return 'Community Activity';
    }
  }
}
