/// Vendor ViewModel
///
/// Manages vendor-related state and business logic.
/// Handles vendor registration, profile management, and vendor operations.
library;

import 'package:flutter/foundation.dart';
import '../data/repositories/vendor_repository.dart';
import '../data/models/vendor_model.dart';
import '../core/utils/logger.dart';

class VendorViewModel extends ChangeNotifier {
  final VendorRepository _vendorRepository;

  VendorViewModel({required VendorRepository vendorRepository})
    : _vendorRepository = vendorRepository;

  // State
  VendorModel? _currentVendor;
  List<VendorModel> _vendors = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  VendorModel? get currentVendor => _currentVendor;
  List<VendorModel> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load vendor by user ID
  Future<void> loadVendorByUserId(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentVendor = await _vendorRepository.getVendorByUserId(userId);
    } catch (e) {
      Logger.error('Failed to load vendor', tag: 'VendorViewModel', error: e);
      _errorMessage = 'Failed to load vendor data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register vendor
  Future<bool> registerVendor(VendorModel vendor) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _vendorRepository.createVendor(vendor);
      _currentVendor = vendor;
      return true;
    } catch (e) {
      Logger.error(
        'Vendor registration failed',
        tag: 'VendorViewModel',
        error: e,
      );
      _errorMessage = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update vendor
  Future<bool> updateVendor(String vendorId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get current vendor data
      final currentVendor = await _vendorRepository.getVendorById(vendorId);
      if (currentVendor == null) {
        throw Exception('Vendor not found');
      }

      // Create updated vendor with new data
      final updatedData = Map<String, dynamic>.from(currentVendor.toJson())
        ..addAll(data);
      updatedData['updatedAt'] = DateTime.now().toIso8601String();

      final updatedVendor = currentVendor.copyWith(
        businessName: updatedData['businessName'],
        businessDescription: updatedData['businessDescription'],
        businessAddress: updatedData['businessAddress'],
        businessPhone: updatedData['businessPhone'],
        businessEmail: updatedData['businessEmail'],
        businessWebsite: updatedData['businessWebsite'],
        updatedAt: DateTime.now(),
      );

      await _vendorRepository.updateVendor(updatedVendor);
      await loadVendorByUserId(_currentVendor?.userId ?? '');
      return true;
    } catch (e) {
      Logger.error('Vendor update failed', tag: 'VendorViewModel', error: e);
      _errorMessage = 'Update failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all vendors
  Future<void> loadVendors({int limit = 20}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _vendors = await _vendorRepository.getTopVendors(limit: limit);
    } catch (e) {
      Logger.error('Failed to load vendors', tag: 'VendorViewModel', error: e);
      _errorMessage = 'Failed to load vendors';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
