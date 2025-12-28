import '../../../../core/app_export.dart';

class AlertBannerWidget extends StatelessWidget {
  final String alertMessage;
  final String alertType;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDismiss;

  const AlertBannerWidget({
    super.key,
    required this.alertMessage,
    required this.alertType,
    this.onViewDetails,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getAlertColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAlertColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getAlertColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAlertIcon(),
              color: _getAlertColor(),
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAlertTitle(),
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getAlertColor(),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  alertMessage,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHighEmphasisLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onViewDetails != null) ...[
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Text(
                      "View Details",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getAlertColor(),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: AppTheme.textSecondary,
                size: 5.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getAlertColor() {
    switch (alertType.toLowerCase()) {
      case 'fraud':
      case 'danger':
        return AppTheme.errorColor;
      case 'warning':
        return AppTheme.warningColor;
      case 'info':
        return AppTheme.primaryBlue;
      case 'success':
        return AppTheme.successColor;
      default:
        return AppTheme.warningColor;
    }
  }

  IconData _getAlertIcon() {
    switch (alertType.toLowerCase()) {
      case 'fraud':
      case 'danger':
        return Icons.dangerous;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notification_important;
    }
  }

  String _getAlertTitle() {
    switch (alertType.toLowerCase()) {
      case 'fraud':
        return 'Fraud Alert';
      case 'danger':
        return 'Security Alert';
      case 'warning':
        return 'Warning';
      case 'info':
        return 'Information';
      case 'success':
        return 'Success';
      default:
        return 'Alert';
    }
  }
}
