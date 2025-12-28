import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart';

class VendorReviewScreen extends StatelessWidget {
  final VendorModel vendor;

  const VendorReviewScreen({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Review'),
        actions: [
          Consumer<AdminViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, value, viewModel),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'approve',
                    child: Text('Approve Vendor'),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Text('Reject Vendor'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVendorInfo(context),
            const SizedBox(height: 24),
            _buildBusinessDetails(context),
            const SizedBox(height: 24),
            _buildDocuments(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Business Name', vendor.businessName),
            _buildInfoRow('Business Type', vendor.businessType),
            _buildInfoRow('Email', vendor.businessEmail ?? 'Not provided'),
            _buildInfoRow('Phone', vendor.businessPhone ?? 'Not provided'),
            _buildInfoRow('Status', vendor.verificationStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Business Address', vendor.businessAddress),
            _buildInfoRow('Registration Number', vendor.registrationNumber),
            _buildInfoRow('Tax ID', vendor.taxId),
            if (vendor.businessWebsite != null)
              _buildInfoRow('Website', vendor.businessWebsite!),
            if (vendor.businessDescription != null)
              _buildInfoRow('Description', vendor.businessDescription!),
          ],
        ),
      ),
    );
  }

  Widget _buildDocuments(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (vendor.documentUrls.isEmpty)
              const Text('No documents uploaded')
            else
              ...vendor.documentUrls.map((url) => ListTile(
                leading: const Icon(Icons.description),
                title: Text('Document ${vendor.documentUrls.indexOf(url) + 1}'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // Open document viewer
                },
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action, AdminViewModel viewModel) {
    switch (action) {
      case 'approve':
        _showApproveDialog(context, viewModel);
        break;
      case 'reject':
        _showRejectDialog(context, viewModel);
        break;
    }
  }

  void _showApproveDialog(BuildContext context, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Vendor'),
        content: Text('Are you sure you want to approve ${vendor.businessName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.approveVendor(vendor.id, 'admin_id_placeholder');
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${vendor.businessName} approved successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminViewModel viewModel) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject ${vendor.businessName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.rejectVendor(
                vendor.id,
                reasonController.text.trim(),
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${vendor.businessName} rejected'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
