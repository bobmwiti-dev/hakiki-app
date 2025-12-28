import '../../../../core/app_export.dart';

class PermissionOverlayWidget extends StatelessWidget {
  final VoidCallback? onRequestPermission;
  final VoidCallback? onOpenSettings;

  const PermissionOverlayWidget({
    super.key,
    this.onRequestPermission,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(230),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera icon
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryBlue,
                  size: 48,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                'Camera Access Required',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              Text(
                'Hakiki needs camera access to scan QR codes and barcodes for product verification. This helps prevent fraud in digital marketplaces.',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(204),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Security features
              _buildFeatureItem(
                icon: Icons.verified_user,
                title: 'Secure Scanning',
                description: 'Your camera data stays on your device',
              ),

              SizedBox(height: 2.h),

              _buildFeatureItem(
                icon: Icons.shield,
                title: 'Fraud Prevention',
                description: 'Verify authentic products instantly',
              ),

              SizedBox(height: 2.h),

              _buildFeatureItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Protected',
                description: 'No images are stored or transmitted',
              ),

              SizedBox(height: 6.h),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRequestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                  ),
                  child: Text(
                    'Allow Camera Access',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              TextButton(
                onPressed: onOpenSettings,
                child: Text(
                  'Open Settings',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.settings,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(179),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
