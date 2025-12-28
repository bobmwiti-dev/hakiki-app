import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/app_export.dart';
import '../../verify/viewmodels/verify_viewmodel.dart';
import 'product_details_screen.dart';

class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({super.key});

  @override
  State<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_controller != null) {
          _controller!.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_controller != null) {
          _controller!.stop();
        }
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });

    if (_hasPermission) {
      _initializeController();
    }
  }

  void _initializeController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_hasPermission && _controller != null)
            IconButton(
              onPressed: () => _controller!.toggleTorch(),
              icon: ValueListenableBuilder(
                valueListenable: _controller!.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  );
                },
              ),
            ),
          IconButton(
            onPressed: _showManualEntryDialog,
            icon: const Icon(Icons.keyboard),
            tooltip: 'Manual Entry',
          ),
        ],
      ),
      body: !_hasPermission
          ? _buildPermissionDeniedView()
          : _controller == null
              ? const Center(child: CircularProgressIndicator())
              : _buildScannerView(),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'To scan QR codes and barcodes, please grant camera permission.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showManualEntryDialog,
              child: const Text('Enter Code Manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        // Scanner View
        MobileScanner(
          controller: _controller,
          onDetect: _onBarcodeDetected,
        ),
        
        // Overlay
        _buildScannerOverlay(),
        
        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomControls(),
        ),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 16,
          borderLength: 30,
          borderWidth: 8,
          cutOutSize: 250,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 300), // Space for scanner area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position QR code or barcode within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(179),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery Button
            _buildControlButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onPressed: _pickFromGallery,
            ),
            
            // Manual Entry Button
            _buildControlButton(
              icon: Icons.keyboard,
              label: 'Manual',
              onPressed: _showManualEntryDialog,
            ),
            
            // Camera Switch Button
            if (_controller != null)
              _buildControlButton(
                icon: Icons.flip_camera_ios,
                label: 'Flip',
                onPressed: () => _controller!.switchCamera(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(204),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;
    
    if (code != null && code.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });
      
      _processScannedCode(code);
    }
  }

  Future<void> _processScannedCode(String code) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying product...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify product using ViewModel
      final viewModel = context.read<VerifyViewModel>();
      final product = await viewModel.verifyProductByCode(code);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (product != null && mounted) {
        // Navigate to product details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: product,
              scannedCode: code,
            ),
          ),
        );
      } else if (mounted) {
        // Show not found dialog
        _showProductNotFoundDialog(code);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Re-enable scanning after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }
    });
  }

  void _showProductNotFoundDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.search_off, color: Colors.orange[700], size: 48),
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No product found with code: $code'),
            const SizedBox(height: 16),
            const Text(
              'This product may not be registered in our system yet. '
              'You can report this if you suspect it might be fraudulent.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reportUnknownProduct(code);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _reportUnknownProduct(String code) {
    // Navigate to report screen with pre-filled data
    Navigator.pushNamed(
      context,
      '/report',
      arguments: {
        'type': 'unknown_product',
        'productCode': code,
        'title': 'Unknown Product Code',
        'description': 'Product with code $code not found in system',
      },
    );
  }

  void _showManualEntryDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Product Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the QR code or barcode manually:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Product Code',
                hintText: 'Enter code here...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                _processScannedCode(code);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      // This would use image_picker to select an image from gallery
      // and then use a QR/barcode detection library to extract codes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallery scanning coming soon!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking from gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Custom overlay shape for scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - cutOutWidth) / 2 + borderWidth,
      rect.top + (height - cutOutHeight) / 2 + borderWidth,
      cutOutWidth - borderWidth * 2,
      cutOutHeight - borderWidth * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    // Draw corner borders
    final borderOffset = borderWidth / 2;
    final leftTopCorner = cutOutRect.topLeft.translate(-borderOffset, -borderOffset);
    final rightTopCorner = cutOutRect.topRight.translate(borderOffset, -borderOffset);
    final leftBottomCorner = cutOutRect.bottomLeft.translate(-borderOffset, borderOffset);
    final rightBottomCorner = cutOutRect.bottomRight.translate(borderOffset, borderOffset);

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(leftTopCorner.dx, leftTopCorner.dy + borderLength)
        ..lineTo(leftTopCorner.dx, leftTopCorner.dy + borderRadius)
        ..quadraticBezierTo(leftTopCorner.dx, leftTopCorner.dy,
            leftTopCorner.dx + borderRadius, leftTopCorner.dy)
        ..lineTo(leftTopCorner.dx + borderLength, leftTopCorner.dy),
      boxPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(rightTopCorner.dx - borderLength, rightTopCorner.dy)
        ..lineTo(rightTopCorner.dx - borderRadius, rightTopCorner.dy)
        ..quadraticBezierTo(rightTopCorner.dx, rightTopCorner.dy,
            rightTopCorner.dx, rightTopCorner.dy + borderRadius)
        ..lineTo(rightTopCorner.dx, rightTopCorner.dy + borderLength),
      boxPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(leftBottomCorner.dx, leftBottomCorner.dy - borderLength)
        ..lineTo(leftBottomCorner.dx, leftBottomCorner.dy - borderRadius)
        ..quadraticBezierTo(leftBottomCorner.dx, leftBottomCorner.dy,
            leftBottomCorner.dx + borderRadius, leftBottomCorner.dy)
        ..lineTo(leftBottomCorner.dx + borderLength, leftBottomCorner.dy),
      boxPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(rightBottomCorner.dx - borderLength, rightBottomCorner.dy)
        ..lineTo(rightBottomCorner.dx - borderRadius, rightBottomCorner.dy)
        ..quadraticBezierTo(rightBottomCorner.dx, rightBottomCorner.dy,
            rightBottomCorner.dx, rightBottomCorner.dy - borderRadius)
        ..lineTo(rightBottomCorner.dx, rightBottomCorner.dy - borderLength),
      boxPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
