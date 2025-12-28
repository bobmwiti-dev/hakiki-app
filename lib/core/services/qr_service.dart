/// QR Code Service
/// 
/// Handles QR code generation and validation.
/// Generates unique QR codes for vendors and products.
library;

import 'package:uuid/uuid.dart';
import '../utils/logger.dart';

class QRService {
  static const Uuid _uuid = Uuid();

  /// Generate a unique QR code for a vendor
  /// Format: VENDOR-{vendorId}-{timestamp}
  static String generateVendorQRCode(String vendorId) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final qrCode = 'VENDOR-$vendorId-$timestamp';
      Logger.info('Generated vendor QR code: $qrCode', tag: 'QRService');
      return qrCode;
    } catch (e) {
      Logger.error('Failed to generate vendor QR code', tag: 'QRService', error: e);
      rethrow;
    }
  }

  /// Generate a unique QR code for a product
  /// Format: PRODUCT-{productId}-{vendorId}
  static String generateProductQRCode(String productId, String vendorId) {
    try {
      final qrCode = 'PRODUCT-$productId-$vendorId';
      Logger.info('Generated product QR code: $qrCode', tag: 'QRService');
      return qrCode;
    } catch (e) {
      Logger.error('Failed to generate product QR code', tag: 'QRService', error: e);
      rethrow;
    }
  }

  /// Parse QR code to extract type and ID
  static Map<String, String>? parseQRCode(String qrCode) {
    try {
      final parts = qrCode.split('-');
      if (parts.length < 2) {
        return null;
      }

      final type = parts[0].toUpperCase();
      final id = parts[1];

      if (type == 'VENDOR') {
        return {
          'type': 'vendor',
          'id': id,
          'raw': qrCode,
        };
      } else if (type == 'PRODUCT') {
        return {
          'type': 'product',
          'id': id,
          'vendorId': parts.length > 2 ? parts[2] : '',
          'raw': qrCode,
        };
      }

      return null;
    } catch (e) {
      Logger.error('Failed to parse QR code', tag: 'QRService', error: e);
      return null;
    }
  }

  /// Validate QR code format
  static bool isValidQRCode(String qrCode) {
    return parseQRCode(qrCode) != null;
  }
}

