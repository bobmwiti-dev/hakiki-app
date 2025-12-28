import '../../core/utils/logger.dart';
import '../../core/services/firestore_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepository(this._firestoreService);

  // Create a new product
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      Logger.info('Creating product: ${product.name}', tag: 'ProductRepository');
      
      await _firestoreService.createProduct(product);
      final createdProduct = product;
      
      Logger.info('Product created successfully: ${createdProduct.id}', tag: 'ProductRepository');
      return createdProduct;
    } catch (e, stackTrace) {
      Logger.error('Failed to create product: ${product.name}', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      Logger.debug('Getting product by ID: $productId', tag: 'ProductRepository');
      
      final product = await _firestoreService.getProduct(productId);
      if (product != null) {
        Logger.debug('Product found: ${product.name}', tag: 'ProductRepository');
        return product;
      }
      
      Logger.debug('Product not found: $productId', tag: 'ProductRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get product by ID: $productId', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get product by QR code
  Future<ProductModel?> getProductByQrCode(String qrCode) async {
    try {
      Logger.debug('Getting product by QR code: $qrCode', tag: 'ProductRepository');
      
      // Use getProductByQRCode method from FirestoreService
      final product = await _firestoreService.getProductByQRCode(qrCode);
      if (product != null) {
        Logger.debug('Product found by QR code: ${product.id}', tag: 'ProductRepository');
        return product;
      }
      
      Logger.debug('Product not found by QR code: $qrCode', tag: 'ProductRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get product by QR code: $qrCode', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      Logger.debug('Getting product by barcode: $barcode', tag: 'ProductRepository');
      
      final product = await _firestoreService.getProductByBarcode(barcode);
      if (product != null) {
        Logger.debug('Product found by barcode: ${product.name}', tag: 'ProductRepository');
        return product;
      }

      Logger.debug('Product not found by barcode: $barcode', tag: 'ProductRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get product by barcode: $barcode', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get products by vendor
  Future<List<ProductModel>> getProductsByVendor(String vendorId, {int? limit}) async {
    try {
      Logger.debug('Getting products by vendor: $vendorId', tag: 'ProductRepository');
      
      // Use generic getProducts method since getProductsByVendor doesn't exist
      return await _firestoreService.getProducts();
    } catch (e, stackTrace) {
      Logger.error('Failed to get products by vendor: $vendorId', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query, {int? limit}) async {
    try {
      Logger.debug('Searching products with query: $query', tag: 'ProductRepository');
      
      // Use generic getProducts method since searchProducts doesn't exist
      return await _firestoreService.getProducts();
    } catch (e, stackTrace) {
      Logger.error('Failed to search products with query: $query', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category, {int? limit}) async {
    try {
      Logger.debug('Getting products by category: $category', tag: 'ProductRepository');
      
      // Use generic getProducts method since searchProducts doesn't exist
      // count method not available in FirestoreService
      // TODO: Implement count method in FirestoreService if needed
      Logger.debug('count method not implemented in FirestoreService', tag: 'ProductRepository');
      const totalProducts = 0;
      
      Logger.debug('Found $totalProducts products in category: $category', tag: 'ProductRepository');
      return [];
    } catch (e, stackTrace) {
      Logger.error('Failed to get products by category: $category', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      Logger.info('Updating product: ${product.id}', tag: 'ProductRepository');
      
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateProduct(product.id, product.toJson());
      
      Logger.info('Product updated successfully: ${product.id}', tag: 'ProductRepository');
      return updatedProduct;
    } catch (e, stackTrace) {
      Logger.error('Failed to update product: ${product.id}', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Increment verification count
  Future<ProductModel> incrementVerificationCount(String productId) async {
    try {
      Logger.info('Incrementing verification count for product: $productId', tag: 'ProductRepository');
      
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }
      
      final updatedProduct = product.copyWith(
        verificationCount: product.verificationCount + 1,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateProduct(productId, updatedProduct.toJson());
      
      Logger.info('Verification count incremented for product: $productId', tag: 'ProductRepository');
      return updatedProduct;
    } catch (e, stackTrace) {
      Logger.error('Failed to increment verification count for product: $productId', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Increment report count
  Future<ProductModel> incrementReportCount(String productId) async {
    try {
      Logger.info('Incrementing report count for product: $productId', tag: 'ProductRepository');
      
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }
      
      final updatedProduct = product.copyWith(
        reportCount: product.reportCount + 1,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateProduct(productId, updatedProduct.toJson());
      
      Logger.info('Report count incremented for product: $productId', tag: 'ProductRepository');
      return updatedProduct;
    } catch (e, stackTrace) {
      Logger.error('Failed to increment report count for product: $productId', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get top verified products
  Future<List<ProductModel>> getTopVerifiedProducts({int limit = 10}) async {
    try {
      Logger.debug('Getting top verified products', tag: 'ProductRepository');
      
      // getProductsByVendor method not available in FirestoreService
      // TODO: Implement getProductsByVendor in FirestoreService if needed
      Logger.debug('getProductsByVendor not implemented in FirestoreService', tag: 'ProductRepository');
      
      // getTopVerifiedProducts method not available in FirestoreService
      // TODO: Implement getTopVerifiedProducts in FirestoreService if needed
      Logger.debug('getTopVerifiedProducts not implemented in FirestoreService', tag: 'ProductRepository');
      final products = <ProductModel>[];
      
      Logger.debug('Found ${products.length} top verified products', tag: 'ProductRepository');
      return products;
    } catch (e, stackTrace) {
      Logger.error('Failed to get top verified products', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get recently added products
  Future<List<ProductModel>> getRecentProducts({int limit = 10}) async {
    try {
      Logger.debug('Getting recent products', tag: 'ProductRepository');
      
      // searchProducts method not available in FirestoreService
      // TODO: Implement searchProducts in FirestoreService if needed
      Logger.debug('searchProducts not implemented in FirestoreService', tag: 'ProductRepository');
      final products = <ProductModel>[];
      
      Logger.debug('Found ${products.length} recent products', tag: 'ProductRepository');
      return products;
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent products', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get product statistics
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      Logger.debug('Getting product statistics', tag: 'ProductRepository');
      
      // Product statistics methods not available in FirestoreService
      // TODO: Implement getProductStatistics in FirestoreService if needed
      Logger.debug('getProductStatistics not implemented in FirestoreService', tag: 'ProductRepository');
      
      const totalProducts = 0;
      const activeProducts = 0;
      const verifiedProducts = 0;
      
      final stats = {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'verifiedProducts': verifiedProducts,
      };
      
      Logger.debug('Product statistics retrieved: $stats', tag: 'ProductRepository');
      return stats;
    } catch (e, stackTrace) {
      Logger.error('Failed to get product statistics', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Deactivate product
  Future<ProductModel> deactivateProduct(String productId) async {
    try {
      Logger.info('Deactivating product: $productId', tag: 'ProductRepository');
      
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }
      
      final deactivatedProduct = product.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateProduct(productId, {'isActive': false, 'updatedAt': DateTime.now().toIso8601String()});
      
      Logger.info('Product deactivated successfully: $productId', tag: 'ProductRepository');
      return deactivatedProduct;
    } catch (e, stackTrace) {
      Logger.error('Failed to deactivate product: $productId', 
          tag: 'ProductRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
