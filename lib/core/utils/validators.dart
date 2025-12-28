import '../constants/app_strings.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid length (10-15 digits)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return AppStrings.invalidPhone;
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : AppStrings.fieldRequired;
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    // Check if name contains only letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Business name validation
  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.trim().length < 2) {
      return 'Business name must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Business name must be less than 100 characters';
    }
    
    return null;
  }

  // OTP validation
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length != 6) {
      return AppStrings.invalidOtp;
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return AppStrings.invalidOtp;
    }
    
    return null;
  }

  // Product ID validation
  static String? validateProductId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    // Product ID should be alphanumeric and at least 3 characters
    if (value.trim().length < 3) {
      return 'Product ID must be at least 3 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
      return 'Product ID can only contain letters and numbers';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value, {int minLength = 10, int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.trim().length < minLength) {
      return 'Description must be at least $minLength characters';
    }
    
    if (value.trim().length > maxLength) {
      return 'Description must be less than $maxLength characters';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional in most cases
    }
    
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return AppStrings.fieldRequired;
    }
    
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    
    if (value.isAfter(eighteenYearsAgo)) {
      return 'You must be at least 18 years old';
    }
    
    return null;
  }

  // File size validation (in bytes)
  static String? validateFileSize(int? sizeInBytes, {int maxSizeInMB = 5}) {
    if (sizeInBytes == null) {
      return AppStrings.fieldRequired;
    }
    
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (sizeInBytes > maxSizeInBytes) {
      return 'File size must be less than ${maxSizeInMB}MB';
    }
    
    return null;
  }

  // File extension validation
  static String? validateFileExtension(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final extension = fileName.toLowerCase().split('.').last;
    if (!allowedExtensions.contains(extension)) {
      return 'Allowed file types: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }
}
