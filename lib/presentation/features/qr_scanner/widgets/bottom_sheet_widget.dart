import '../../../../core/app_export.dart';

class ScannerBottomSheetWidget extends StatefulWidget {
  final VoidCallback? onScanHistory;
  final VoidCallback? onHowToScan;
  final Function(String)? onManualEntry;

  const ScannerBottomSheetWidget({
    super.key,
    this.onScanHistory,
    this.onHowToScan,
    this.onManualEntry,
  });

  @override
  State<ScannerBottomSheetWidget> createState() =>
      _ScannerBottomSheetWidgetState();
}

class _ScannerBottomSheetWidgetState extends State<ScannerBottomSheetWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _showManualEntry = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child:
                  _showManualEntry ? _buildManualEntry() : _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scanner Options',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 3.h),

        // Manual barcode entry button
        _buildOptionTile(
          icon: Icons.keyboard,
          title: 'Enter Barcode Manually',
          subtitle: 'Type the barcode number directly',
          onTap: () {
            setState(() {
              _showManualEntry = true;
            });
          },
        ),

        SizedBox(height: 2.h),

        // Scan history button
        _buildOptionTile(
          icon: Icons.history,
          title: 'Scan History',
          subtitle: 'View previously scanned codes',
          onTap: widget.onScanHistory,
        ),

        SizedBox(height: 2.h),

        // How to scan help
        _buildOptionTile(
          icon: Icons.help_outline,
          title: 'How to Scan',
          subtitle: 'Learn scanning tips and tricks',
          onTap: widget.onHowToScan,
        ),
      ],
    );
  }

  Widget _buildManualEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _showManualEntry = false;
                  _barcodeController.clear();
                });
              },
              icon: Icon(
                Icons.arrow_back,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
            Text(
              'Enter Barcode',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Barcode input field
        TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Barcode Number',
            hintText: 'Enter 12-13 digit barcode',
            prefixIcon: const Icon(Icons.qr_code_scanner),
            suffixIcon: _barcodeController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _barcodeController.clear();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.clear,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),

        SizedBox(height: 3.h),

        // Verify button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _barcodeController.text.length >= 8
                ? () {
                    widget.onManualEntry?.call(_barcodeController.text);
                  }
                : null,
            child: const Text('Verify Product'),
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Enter the barcode number found on the product packaging',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
