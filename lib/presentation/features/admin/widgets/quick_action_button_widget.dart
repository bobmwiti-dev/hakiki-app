import '../../../../core/app_export.dart';

class QuickActionButtonWidget extends StatelessWidget {
  final String title;
  final String iconName;
  final int? badgeCount;
  final VoidCallback onTap;

  const QuickActionButtonWidget({
    super.key,
    required this.title,
    required this.iconName,
    this.badgeCount,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'store':
        return Icons.store;
      case 'priority_high':
        return Icons.priority_high;
      case 'pending_actions':
        return Icons.pending_actions;
      case 'report_problem':
        return Icons.report_problem;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'verified':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 12.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  _getIconData(iconName),
                  color: Colors.blue,
                  size: 6.w,
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -1.w,
                    top: -0.5.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                      child: Text(
                        badgeCount! > 99 ? '99+' : badgeCount.toString(),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
