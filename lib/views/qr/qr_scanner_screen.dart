/// QR Scanner Screen
///
/// Allows users to scan QR codes to verify products.
/// Uses camera to capture QR code data.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/product_model.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.scanQrCode)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera preview placeholder
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Position QR code within the frame',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Create mock product for demonstration
                final mockProduct = ProductModel(
                  id: 'demo-product-${DateTime.now().millisecondsSinceEpoch}',
                  vendorId: 'demo-vendor-001',
                  name: 'iPhone 15 Pro Max',
                  description:
                      'Latest iPhone with advanced camera system and A17 Pro chip',
                  category: 'Electronics',
                  brand: 'Apple',
                  model: 'iPhone 15 Pro Max',
                  serialNumber: 'DEMO-SERIAL-123',
                  price: 1199.99,
                  currency: 'USD',
                  imageUrls: [],
                  specifications: {},
                  isVerified: true,
                  isActive: true,
                  verificationCount: 1,
                  reportCount: 0,
                  averageRating: 4.5,
                  totalRatings: 10,
                  qrCode: 'DEMO-QR-CODE-123',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                Navigator.of(context).pushNamed(
                  AppRoutes.productVerification,
                  arguments: {'type': 'product', 'product': mockProduct},
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan QR Code'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showManualEntryDialog(context),
              child: const Text('Enter Product ID Manually'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManualEntryDialog(BuildContext context) async {
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter QR/Barcode Code'),
            content: TextField(
              controller: codeController,
              decoration: const InputDecoration(
                hintText: 'Paste or type the code here',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
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
                    _handleQRCode(code);
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          ),
    );

    codeController.dispose();
  }

  void _handleQRCode(String code) {
    // Create mock product for demonstration based on entered code
    final mockProduct = ProductModel(
      id: 'manual-product-${DateTime.now().millisecondsSinceEpoch}',
      vendorId: 'manual-vendor-001',
      name: code.length > 5 ? 'Samsung Galaxy S24 Ultra' : 'Nike Air Max Shoes',
      description: 'Product scanned manually with code: $code',
      category: code.length > 5 ? 'Electronics' : 'Fashion',
      brand: code.length > 5 ? 'Samsung' : 'Nike',
      model: code.length > 5 ? 'Galaxy S24 Ultra' : 'Air Max',
      serialNumber: 'MANUAL-${code.hashCode}',
      price: code.length > 5 ? 1299.99 : 199.99,
      currency: 'USD',
      imageUrls: [],
      specifications: {},
      isVerified: code.length > 3, // Simple verification logic for demo
      isActive: true,
      verificationCount: code.length > 3 ? 1 : 0,
      reportCount: 0,
      averageRating: 4.0,
      totalRatings: 5,
      qrCode: code,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pushNamed(
      AppRoutes.productVerification,
      arguments: {'type': 'product', 'product': mockProduct},
    );
  }
}
