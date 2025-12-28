import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductViewModel(this._productRepository);

  ProductModel? _currentProduct;
  List<ProductModel> _products = [];
  List<ProductModel> _vendorProducts = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _productStats;

  // Getters
  ProductModel? get currentProduct => _currentProduct;
  List<ProductModel> get products => _products;
  List<ProductModel> get vendorProducts => _vendorProducts;
  List<ProductModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get productStats => _productStats;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setCurrentProduct(ProductModel? product) {
    _currentProduct = product;
    notifyListeners();
  }

  void _setProducts(List<ProductModel> products) {
    _products = products;
    notifyListeners();
  }

  void _setVendorProducts(List<ProductModel> products) {
    _vendorProducts = products;
    notifyListeners();
  }

  void _setSearchResults(List<ProductModel> products) {
    _searchResults = products;
    notifyListeners();
  }

  void _setProductStats(Map<String, dynamic>? stats) {
    _productStats = stats;
    notifyListeners();
  }

  // Create product
  Future<bool> createProduct(ProductModel product) async {
    try {
      Logger.info('Creating product: ${product.name}', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final createdProduct = await _productRepository.createProduct(product);
      _setCurrentProduct(createdProduct);
      
      // Add to vendor products list if it exists
      if (_vendorProducts.isNotEmpty) {
        _vendorProducts.insert(0, createdProduct);
        notifyListeners();
      }
      
      Logger.info('Product created successfully: ${createdProduct.id}', tag: 'ProductViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to create product: ${product.name}', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to create product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get product by ID
  Future<void> getProductById(String productId) async {
    try {
      Logger.debug('Getting product by ID: $productId', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final product = await _productRepository.getProductById(productId);
      _setCurrentProduct(product);
      
      if (product != null) {
        Logger.debug('Product found: ${product.name}', tag: 'ProductViewModel');
      } else {
        Logger.debug('Product not found: $productId', tag: 'ProductViewModel');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get product by ID: $productId', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load product');
    } finally {
      _setLoading(false);
    }
  }

  // Verify product by QR code
  Future<ProductModel?> verifyProductByQrCode(String qrCode) async {
    try {
      Logger.info('Verifying product by QR code: $qrCode', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final product = await _productRepository.getProductByQrCode(qrCode);
      _setCurrentProduct(product);
      
      if (product != null) {
        // Increment verification count
        await _productRepository.incrementVerificationCount(product.id);
        Logger.info('Product verified: ${product.name}', tag: 'ProductViewModel');
      } else {
        Logger.info('Product not found for QR code: $qrCode', tag: 'ProductViewModel');
      }
      
      return product;
    } catch (e, stackTrace) {
      Logger.error('Failed to verify product by QR code: $qrCode', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to verify product');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Verify product by barcode
  Future<ProductModel?> verifyProductByBarcode(String barcode) async {
    try {
      Logger.info('Verifying product by barcode: $barcode', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final product = await _productRepository.getProductByBarcode(barcode);
      _setCurrentProduct(product);
      
      if (product != null) {
        // Increment verification count
        await _productRepository.incrementVerificationCount(product.id);
        Logger.info('Product verified: ${product.name}', tag: 'ProductViewModel');
      } else {
        Logger.info('Product not found for barcode: $barcode', tag: 'ProductViewModel');
      }
      
      return product;
    } catch (e, stackTrace) {
      Logger.error('Failed to verify product by barcode: $barcode', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to verify product');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get products by vendor
  Future<void> getProductsByVendor(String vendorId, {int? limit}) async {
    try {
      Logger.debug('Getting products by vendor: $vendorId', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final products = await _productRepository.getProductsByVendor(vendorId, limit: limit);
      _setVendorProducts(products);
      
      Logger.debug('Found ${products.length} products for vendor: $vendorId', tag: 'ProductViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get products by vendor: $vendorId', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load vendor products');
    } finally {
      _setLoading(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query, {int? limit}) async {
    try {
      Logger.debug('Searching products with query: $query', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final products = await _productRepository.searchProducts(query, limit: limit);
      _setSearchResults(products);
      
      Logger.debug('Found ${products.length} products matching query: $query', tag: 'ProductViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to search products with query: $query', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to search products');
    } finally {
      _setLoading(false);
    }
  }

  // Get products by category
  Future<void> getProductsByCategory(String category, {int? limit}) async {
    try {
      Logger.debug('Getting products by category: $category', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final products = await _productRepository.getProductsByCategory(category, limit: limit);
      _setProducts(products);
      
      Logger.debug('Found ${products.length} products in category: $category', tag: 'ProductViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get products by category: $category', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load products');
    } finally {
      _setLoading(false);
    }
  }

  // Get top verified products
  Future<void> getTopVerifiedProducts({int limit = 10}) async {
    try {
      Logger.debug('Getting top verified products', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final products = await _productRepository.getTopVerifiedProducts(limit: limit);
      _setProducts(products);
      
      Logger.debug('Found ${products.length} top verified products', tag: 'ProductViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get top verified products', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load top products');
    } finally {
      _setLoading(false);
    }
  }

  // Get recent products
  Future<void> getRecentProducts({int limit = 10}) async {
    try {
      Logger.debug('Getting recent products', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final products = await _productRepository.getRecentProducts(limit: limit);
      _setProducts(products);
      
      Logger.debug('Found ${products.length} recent products', tag: 'ProductViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent products', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load recent products');
    } finally {
      _setLoading(false);
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      Logger.info('Updating product: ${product.id}', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final updatedProduct = await _productRepository.updateProduct(product);
      _setCurrentProduct(updatedProduct);
      
      Logger.info('Product updated successfully: ${product.id}', tag: 'ProductViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update product: ${product.id}', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Report product as fraudulent
  Future<bool> reportProduct(String productId) async {
    try {
      Logger.info('Reporting product as fraudulent: $productId', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final updatedProduct = await _productRepository.incrementReportCount(productId);
      
      // Update current product if it's the same
      if (_currentProduct?.id == productId) {
        _setCurrentProduct(updatedProduct);
      }
      
      Logger.info('Product reported successfully: $productId', tag: 'ProductViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to report product: $productId', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to report product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Deactivate product
  Future<bool> deactivateProduct(String productId) async {
    try {
      Logger.info('Deactivating product: $productId', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final deactivatedProduct = await _productRepository.deactivateProduct(productId);
      
      // Update current product if it's the same
      if (_currentProduct?.id == productId) {
        _setCurrentProduct(deactivatedProduct);
      }
      
      // Remove from vendor products list
      _vendorProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
      
      Logger.info('Product deactivated successfully: $productId', tag: 'ProductViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to deactivate product: $productId', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to deactivate product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get product statistics
  Future<void> getProductStatistics() async {
    try {
      Logger.debug('Getting product statistics', tag: 'ProductViewModel');
      _setLoading(true);
      _setError(null);

      final stats = await _productRepository.getProductStats();
      _setProductStats(stats);
      
      Logger.debug('Product statistics retrieved', tag: 'ProductViewModel');
    } catch (e, stackTrace) {
      Logger.error('Failed to get product statistics', 
          tag: 'ProductViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to load product statistics');
    } finally {
      _setLoading(false);
    }
  }

  // Get trust level color
  String getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'High':
        return 'green';
      case 'Medium':
        return 'orange';
      case 'Low':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Check if product is suspicious
  bool isProductSuspicious(ProductModel product) {
    return product.reportCount > product.verificationCount ||
           product.reportCount >= 5 ||
           product.trustLevel == 'Low';
  }

  // Get verification status text
  String getVerificationStatusText(ProductModel product) {
    if (product.isVerified) {
      return 'Verified Product';
    } else if (isProductSuspicious(product)) {
      return 'Suspicious Product';
    } else {
      return 'Unverified Product';
    }
  }

  void clearError() {
    _setError(null);
  }

  void clearProducts() {
    _setProducts([]);
  }

  void clearVendorProducts() {
    _setVendorProducts([]);
  }

  void clearSearchResults() {
    _setSearchResults([]);
  }
}
