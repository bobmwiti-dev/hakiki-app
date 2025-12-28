import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/app_export.dart';
import '../widgets/bottom_sheet_widget.dart';
import '../widgets/camera_controls_widget.dart';
import '../widgets/permission_overlay_widget.dart';
import '../widgets/scan_instruction_widget.dart';
import '../widgets/scanning_frame_widget.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner>
    with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _isTorchOn = false;
  bool _showInstructions = true;
  bool _isInitialized = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  // Mock scan history data
  final List<Map<String, dynamic>> _scanHistory = [
    {
      "id": 1,
      "code": "1234567890123",
      "type": "Barcode",
      "product": "Samsung Galaxy Phone",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "Verified",
    },
    {
      "id": 2,
      "code": "QR_ABC123XYZ",
      "type": "QR Code",
      "product": "Nike Air Max Shoes",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "status": "Authentic",
    },
    {
      "id": 3,
      "code": "9876543210987",
      "type": "Barcode",
      "product": "Apple iPhone Case",
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "status": "Warning",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();

    // Hide instructions after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showInstructions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController?.start();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _scannerController?.stop();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeScanner() async {
    try {
      final hasPermission = await _requestCameraPermission();

      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
        });
        return;
      }

      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      await _scannerController!.start();

      setState(() {
        _hasPermission = true;
        _isInitialized = true;
        _isScanning = true;
      });
    } catch (e) {
      debugPrint('Error initializing scanner: $e');
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    // Prevent duplicate scans within 2 seconds
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inSeconds < 2) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show success animation
    _showScanSuccess();

    // Navigate to verification results
    _navigateToVerification(code, barcode.type.name);
  }

  void _showScanSuccess() {
    // Green flash animation
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.green.withAlpha(77),
      builder: (context) {
        final navigator = Navigator.of(context);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            navigator.pop();
          }
        });

        return Center(
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),
        );
      },
    );
  }

  void _navigateToVerification(String code, String type) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/product-verification-results',
          arguments: {
            'code': code,
            'type': type,
            'timestamp': DateTime.now(),
          },
        );
      }
    });
  }

  void _toggleTorch() async {
    if (_scannerController == null) return;

    try {
      await _scannerController!.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      debugPrint('Error toggling torch: $e');
    }
  }

  void _onManualEntry(String code) {
    if (code.isEmpty) return;

    HapticFeedback.lightImpact();
    Navigator.pop(context); // Close bottom sheet
    _navigateToVerification(code, 'Manual Entry');
  }

  void _showScanHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScanHistorySheet(),
    );
  }

  void _showHowToScan() {
    showDialog(
      context: context,
      builder: (context) => _buildHowToScanDialog(),
    );
  }

  Widget _buildScanHistorySheet() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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

          Padding(
            padding: EdgeInsets.all(6.w),
            child: Row(
              children: [
                Text(
                  'Scan History',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              itemCount: _scanHistory.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final item = _scanHistory[index];
                return _buildHistoryItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final status = item["status"] as String;
    Color statusColor = Colors.green;

    if (status == "Warning") {
      statusColor = Colors.orange;
    } else if (status == "Failed") {
      statusColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item["product"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '${item["type"]}: ${item["code"]}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            _formatTimestamp(item["timestamp"] as DateTime),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToScanDialog() {
    return AlertDialog(
      title: const Text('How to Scan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipItem(
            icon: Icons.center_focus_strong,
            title: 'Position the Code',
            description:
                'Align the QR code or barcode within the scanning frame',
          ),
          SizedBox(height: 2.h),
          _buildTipItem(
            icon: Icons.wb_sunny,
            title: 'Good Lighting',
            description: 'Ensure adequate lighting or use the torch button',
          ),
          SizedBox(height: 2.h),
          _buildTipItem(
            icon: Icons.straighten,
            title: 'Hold Steady',
            description: 'Keep your device steady for best scanning results',
          ),
          SizedBox(height: 2.h),
          _buildTipItem(
            icon: Icons.keyboard,
            title: 'Manual Entry',
            description: 'Use manual entry if scanning is not working',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.lightTheme.primaryColor,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or permission overlay
          if (!_hasPermission)
            PermissionOverlayWidget(
              onRequestPermission: _initializeScanner,
              onOpenSettings: () async {
                await openAppSettings();
              },
            )
          else if (_isInitialized && _scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onDetect,
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),

          // Camera controls (top)
          if (_hasPermission && _isInitialized)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CameraControlsWidget(
                isTorchOn: _isTorchOn,
                canToggleTorch: !kIsWeb,
                onTorchToggle: _toggleTorch,
                onClose: () => Navigator.pop(context),
              ),
            ),

          // Scanning frame (center)
          if (_hasPermission && _isInitialized)
            Center(
              child: ScanningFrameWidget(
                isScanning: _isScanning,
                onTap: () {
                  setState(() {
                    _showInstructions = !_showInstructions;
                  });
                },
              ),
            ),

          // Scan instructions
          if (_hasPermission && _isInitialized)
            Positioned(
              top: 40.h,
              left: 0,
              right: 0,
              child: ScanInstructionWidget(
                isVisible: _showInstructions,
              ),
            ),

          // Bottom sheet
          if (_hasPermission && _isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ScannerBottomSheetWidget(
                onScanHistory: _showScanHistory,
                onHowToScan: _showHowToScan,
                onManualEntry: _onManualEntry,
              ),
            ),
        ],
      ),
    );
  }
}
