/// Product ViewModel
/// 
/// Manages product-related state and business logic.
/// Handles product verification, listing, and product operations.
library;

import 'package:flutter/foundation.dart';
import '../data/repositories/product_repository.dart';
import '../data/models/product_model.dart';
import '../core/utils/logger.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductViewModel({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository;

  // State
  ProductModel? _selectedProduct;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ProductModel? get selectedProduct => _selectedProduct;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Verify product by QR code
  Future<ProductModel?> verifyProductByQRCode(String qrCode) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedProduct = await _productRepository.getProductByQrCode(qrCode);
      return _selectedProduct;
    } catch (e) {
      Logger.error('Product verification failed', tag: 'ProductViewModel', error: e);
      _errorMessage = 'Verification failed: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify product by barcode
  Future<ProductModel?> verifyProductByBarcode(String barcode) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedProduct = await _productRepository.getProductByBarcode(barcode);
      return _selectedProduct;
    } catch (e) {
      Logger.error('Product verification failed', tag: 'ProductViewModel', error: e);
      _errorMessage = 'Verification failed: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load product by ID
  Future<void> loadProduct(String productId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedProduct = await _productRepository.getProductById(productId);
    } catch (e) {
      Logger.error('Failed to load product', tag: 'ProductViewModel', error: e);
      _errorMessage = 'Failed to load product';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load products
  Future<void> loadProducts({int limit = 20}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _products = await _productRepository.getRecentProducts(limit: limit);
    } catch (e) {
      Logger.error('Failed to load products', tag: 'ProductViewModel', error: e);
      _errorMessage = 'Failed to load products';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selection
  void clearSelection() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

