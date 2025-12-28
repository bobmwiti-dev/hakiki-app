import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  StorageService({required FirebaseStorage storage}) : _storage = storage;

  // Upload profile image
  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final fileName = '${userId}_${_uuid.v4()}.${_getFileExtension(file.path)}';
      final ref = _storage.ref().child('${AppConstants.profileImagesPath}/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload document (for vendor registration)
  Future<String> uploadDocument(File file, String userId) async {
    try {
      final fileName = '${userId}_${_uuid.v4()}.${_getFileExtension(file.path)}';
      final ref = _storage.ref().child('${AppConstants.documentsPath}/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Upload product image
  Future<String> uploadProductImage(File file, String productId) async {
    try {
      final fileName = '${productId}_${_uuid.v4()}.${_getFileExtension(file.path)}';
      final ref = _storage.ref().child('${AppConstants.productImagesPath}/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }

  // Upload report media
  Future<String> uploadReportMedia(File file, String reportId) async {
    try {
      final fileName = '${reportId}_${_uuid.v4()}.${_getFileExtension(file.path)}';
      final ref = _storage.ref().child('${AppConstants.reportMediaPath}/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload report media: $e');
    }
  }

  // Upload multiple files
  Future<List<String>> uploadMultipleFiles(
    List<File> files,
    String folder,
    String prefix,
  ) async {
    try {
      final uploadTasks = files.map((file) async {
        final fileName = '${prefix}_${_uuid.v4()}.${_getFileExtension(file.path)}';
        final ref = _storage.ref().child('$folder/$fileName');
        
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        
        return await snapshot.ref.getDownloadURL();
      });

      return await Future.wait(uploadTasks);
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Delete multiple files
  Future<void> deleteMultipleFiles(List<String> urls) async {
    try {
      final deleteTasks = urls.map((url) async {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      });

      await Future.wait(deleteTasks);
    } catch (e) {
      throw Exception('Failed to delete multiple files: $e');
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  // Check if file exists
  Future<bool> fileExists(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate file size
  bool validateFileSize(File file, {int? maxSizeBytes}) {
    final fileSize = file.lengthSync();
    final maxSize = maxSizeBytes ?? AppConstants.maxFileSize;
    return fileSize <= maxSize;
  }

  // Validate file type
  bool validateFileType(String filePath, List<String> allowedTypes) {
    final extension = _getFileExtension(filePath).toLowerCase();
    return allowedTypes.contains(extension);
  }

  // Validate image file
  bool validateImageFile(File file) {
    return validateFileSize(file) && 
           validateFileType(file.path, AppConstants.allowedImageTypes);
  }

  // Validate document file
  bool validateDocumentFile(File file) {
    return validateFileSize(file) && 
           validateFileType(file.path, AppConstants.allowedDocumentTypes);
  }

  // Get file extension
  String _getFileExtension(String filePath) {
    return filePath.split('.').last;
  }

  // Get file size in MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Compress image (placeholder - would need image compression package)
  Future<File> compressImage(File file) async {
    // Image compression would be implemented here using flutter_image_compress
    // This would reduce file size for better performance and storage efficiency
    return file;
  }

  // Generate thumbnail (placeholder)
  Future<File> generateThumbnail(File file) async {
    // Thumbnail generation would be implemented here for image previews
    // This would create smaller versions for faster loading in lists
    return file;
  }
}
