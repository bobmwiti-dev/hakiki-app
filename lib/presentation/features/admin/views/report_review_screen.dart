import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/report_model.dart';
import '../viewmodels/admin_viewmodel.dart';

class ReportReviewScreen extends StatelessWidget {
  final ReportModel report;

  const ReportReviewScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Review'),
        actions: [
          Consumer<AdminViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, value, viewModel),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'approve',
                    child: Text('Approve Report'),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Text('Reject Report'),
                  ),
                  const PopupMenuItem(
                    value: 'investigate',
                    child: Text('Mark as Investigating'),
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
            _buildReportInfo(context),
            const SizedBox(height: 24),
            _buildReportDetails(context),
            const SizedBox(height: 24),
            _buildEvidence(context),
            const SizedBox(height: 24),
            _buildMediaFiles(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReportInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Title', report.title),
            _buildInfoRow('Type', report.type),
            _buildInfoRow('Status', report.status),
            _buildInfoRow('Severity', '${report.severity}/5'),
            _buildInfoRow('Anonymous', report.isAnonymous ? 'Yes' : 'No'),
            _buildInfoRow('Created', _formatDate(report.createdAt)),
            _buildInfoRow('Updated', _formatDate(report.updatedAt)),
            if (report.resolvedAt != null)
              _buildInfoRow('Resolved', _formatDate(report.resolvedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (report.resolution != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Resolution:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.resolution!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEvidence(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evidence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (report.evidence.isEmpty)
              const Text('No evidence provided')
            else
              ...report.evidence.entries.map((entry) => 
                _buildInfoRow(entry.key, entry.value.toString())
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaFiles(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media Files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (report.mediaUrls.isEmpty)
              const Text('No media files attached')
            else
              ...report.mediaUrls.map((url) => ListTile(
                leading: const Icon(Icons.attachment),
                title: Text('Media ${report.mediaUrls.indexOf(url) + 1}'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // Open media viewer
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleAction(BuildContext context, String action, AdminViewModel viewModel) {
    switch (action) {
      case 'approve':
        _showApproveDialog(context, viewModel);
        break;
      case 'reject':
        _showRejectDialog(context, viewModel);
        break;
      case 'investigate':
        _showInvestigateDialog(context, viewModel);
        break;
    }
  }

  void _showApproveDialog(BuildContext context, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Report'),
        content: Text('Are you sure you want to approve this report: "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.approveReport(report.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Report approved successfully'),
                    backgroundColor: Theme.of(context).colorScheme.surface,
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
        title: const Text('Reject Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject this report: "${report.title}"?'),
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
              await viewModel.rejectReport(
                report.id,
                reasonController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Report rejected'),
                    backgroundColor: Theme.of(context).colorScheme.surface,
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

  void _showInvestigateDialog(BuildContext context, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Investigating'),
        content: Text('Mark this report as under investigation: "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.updateReportStatus(report.id, 'investigating');
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report marked as investigating'),
                  ),
                );
              }
            },
            child: const Text('Mark as Investigating'),
          ),
        ],
      ),
    );
  }
}
