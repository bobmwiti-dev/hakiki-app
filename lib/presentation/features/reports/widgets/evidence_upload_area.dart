import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';


class EvidenceUploadArea extends StatefulWidget {
  final List<XFile> selectedFiles;
  final Function(List<XFile>) onFilesSelected;

  const EvidenceUploadArea({
    super.key,
    required this.selectedFiles,
    required this.onFilesSelected,
  });

  @override
  State<EvidenceUploadArea> createState() => _EvidenceUploadAreaState();
}

class _EvidenceUploadAreaState extends State<EvidenceUploadArea> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickFromCamera() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          _showPermissionDialog('Camera');
          return;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        final updatedFiles = List<XFile>.from(widget.selectedFiles)..add(photo);
        widget.onFilesSelected(updatedFiles);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted) {
          _showPermissionDialog('Photos');
          return;
        }
      }

      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photos.isNotEmpty) {
        final updatedFiles = List<XFile>.from(widget.selectedFiles)
          ..addAll(photos);
        widget.onFilesSelected(updatedFiles);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select photos');
    }
  }

  Future<void> _pickVideo() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          _showPermissionDialog('Camera');
          return;
        }
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        final updatedFiles = List<XFile>.from(widget.selectedFiles)..add(video);
        widget.onFilesSelected(updatedFiles);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select video');
    }
  }

  Future<void> _pickFiles() async {
    try {
      setState(() => _isUploading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );

      if (result != null) {
        final List<XFile> files = result.files
            .map((file) => XFile(file.path ?? ''))
            .where((file) => file.path.isNotEmpty)
            .toList();

        if (files.isNotEmpty) {
          final updatedFiles = List<XFile>.from(widget.selectedFiles)
            ..addAll(files);
          widget.onFilesSelected(updatedFiles);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select files');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeFile(int index) {
    final updatedFiles = List<XFile>.from(widget.selectedFiles)
      ..removeAt(index);
    widget.onFilesSelected(updatedFiles);
  }

  void _showPermissionDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text('$permission permission is required to upload evidence.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'doc':
      case 'docx':
        return 'description';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'videocam';
      default:
        return 'image';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence Upload',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Upload photos, videos, or documents as evidence',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFromCamera,
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFromGallery,
                icon: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickVideo,
                icon: Icon(
                  Icons.videocam,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
                label: const Text('Video'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFiles,
                icon: _isUploading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      )
                    : Icon(
                        Icons.attach_file,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                label: const Text('Files'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
          ],
        ),
        if (widget.selectedFiles.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            'Selected Files (${widget.selectedFiles.length})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 1,
            ),
            itemCount: widget.selectedFiles.length,
            itemBuilder: (context, index) {
              final file = widget.selectedFiles[index];
              final fileName = file.name;
              final isImage = fileName
                  .toLowerCase()
                  .contains(RegExp(r'\.(jpg|jpeg|png|gif)$'));

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isImage
                          ? kIsWeb
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.black54,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  File(file.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(
                                  _getIconData(_getFileIcon(fileName)),
                                  color: Colors.black54,
                                  size: 24,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 1.w,
                    right: 1.w,
                    child: GestureDetector(
                      onTap: () => _removeFile(index),
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'picture_as_pdf':
        return Icons.picture_as_pdf;
      case 'description':
        return Icons.description;
      case 'videocam':
        return Icons.videocam;
      default:
        return Icons.image;
    }
  }
}
