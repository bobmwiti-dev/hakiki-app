/// Vendor Review Screen
/// 
/// Admin screen for reviewing and approving/rejecting vendor applications.
library;

import 'package:flutter/material.dart';
import '../../data/models/vendor_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/utils/logger.dart';

class VendorReviewScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorReviewScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<VendorReviewScreen> createState() => _VendorReviewScreenState();
}

class _VendorReviewScreenState extends State<VendorReviewScreen> {
  final _rejectionReasonController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepositoryImpl();
  bool _isProcessing = false;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveVendor() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final admin = FirebaseAuthService().currentUser;
      if (admin == null) throw Exception('Admin not authenticated');

      await _adminRepository.approveVendor(widget.vendor.id, admin.uid);

      // Notification will be sent via Cloud Function
      Logger.info('Vendor approved, notification will be sent via Cloud Function', tag: 'VendorReviewScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Logger.error('Failed to approve vendor', tag: 'VendorReviewScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _rejectVendor() async {
    if (_rejectionReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rejection reason')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _adminRepository.rejectVendor(
        widget.vendor.id,
        _rejectionReasonController.text.trim(),
      );

      // Notification will be sent via Cloud Function
      Logger.info('Vendor rejected, notification will be sent via Cloud Function', tag: 'VendorReviewScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Logger.error('Failed to reject vendor', tag: 'VendorReviewScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Vendor Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vendor.businessName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${widget.vendor.businessType}'),
                    Text('Address: ${widget.vendor.businessAddress}'),
                    if (widget.vendor.businessPhone != null)
                      Text('Phone: ${widget.vendor.businessPhone}'),
                    if (widget.vendor.businessEmail != null)
                      Text('Email: ${widget.vendor.businessEmail}'),
                    Text('Registration: ${widget.vendor.registrationNumber}'),
                    Text('Tax ID: ${widget.vendor.taxId}'),
                    if (widget.vendor.businessDescription != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Description:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(widget.vendor.businessDescription!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Documents
            if (widget.vendor.documentUrls.isNotEmpty) ...[
              Text(
                'Documents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...widget.vendor.documentUrls.map((url) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(url.split('/').last),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // Open document URL in browser
                      },
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Rejection reason (if rejecting)
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Required for rejection)',
                hintText: 'Explain why the application is being rejected',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _rejectVendor,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _approveVendor,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

