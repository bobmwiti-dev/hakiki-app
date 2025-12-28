/// Report Review Screen
/// 
/// Admin screen for reviewing and resolving fraud reports.
library;

import 'package:flutter/material.dart';
import '../../data/models/fraud_report_model.dart';
import '../../data/repositories/fraud_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/utils/logger.dart';

class ReportReviewScreen extends StatefulWidget {
  final FraudReportModel report;

  const ReportReviewScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  final _resolutionController = TextEditingController();
  final FraudRepository _fraudRepository = FraudRepository(FirestoreService());
  String _selectedStatus = 'investigating';
  bool _isProcessing = false;

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _updateReportStatus() async {
    if (_selectedStatus == 'resolved' && _resolutionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a resolution')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final admin = FirebaseAuthService().currentUser;
      if (admin == null) throw Exception('Admin not authenticated');

      await _fraudRepository.resolveReport(
        widget.report.id,
        _resolutionController.text.trim(),
        admin.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Logger.error('Failed to update report', tag: 'ReportReviewScreen', error: e);
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
        title: const Text('Review Fraud Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.report.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${widget.report.type}'),
                    Text('Severity: ${widget.report.severity}/5'),
                    Text('Status: ${widget.report.status}'),
                    Text('Created: ${_formatDate(widget.report.createdAt)}'),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.report.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Evidence
            if (widget.report.mediaUrls.isNotEmpty) ...[
              Text(
                'Evidence (${widget.report.mediaUrls.length} files)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...widget.report.mediaUrls.map((url) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.attachment),
                      title: Text(url.split('/').last),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // Open media URL
                      },
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Status update
            Text(
              'Update Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'investigating',
                  child: Text('Under Investigation'),
                ),
                DropdownMenuItem(
                  value: 'resolved',
                  child: Text('Resolved'),
                ),
                DropdownMenuItem(
                  value: 'dismissed',
                  child: Text('Dismissed'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // Resolution
            if (_selectedStatus == 'resolved')
              TextField(
                controller: _resolutionController,
                decoration: const InputDecoration(
                  labelText: 'Resolution',
                  hintText: 'Describe how this report was resolved',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            const SizedBox(height: 24),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _updateReportStatus,
                icon: const Icon(Icons.save),
                label: const Text('Update Report'),
              ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

