import '../../../../core/app_export.dart';

class CameraControlsWidget extends StatelessWidget {
  final bool isTorchOn;
  final bool canToggleTorch;
  final VoidCallback? onTorchToggle;
  final VoidCallback? onClose;

  const CameraControlsWidget({
    super.key,
    required this.isTorchOn,
    required this.canToggleTorch,
    this.onTorchToggle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.all(2.w),
              ),
            ),

            // Torch toggle button
            if (canToggleTorch)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onTorchToggle,
                  icon: Icon(
                    isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: isTorchOn ? Colors.yellow : Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.all(2.w),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
