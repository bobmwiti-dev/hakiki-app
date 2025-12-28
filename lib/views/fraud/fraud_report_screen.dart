/// Fraud Report Screen
/// 
/// Allows users to report fraud, fake products, or suspicious vendors.
/// Collects report details and evidence.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/activity_service.dart';
import '../../data/models/fraud_report_model.dart';
import '../../data/repositories/fraud_repository.dart';

class FraudReportScreen extends StatefulWidget {
  final String? productId;
  final String? vendorId;

  const FraudReportScreen({
    super.key,
    this.productId,
    this.vendorId,
  });

  @override
  State<FraudReportScreen> createState() => _FraudReportScreenState();
}

class _FraudReportScreenState extends State<FraudReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ActivityService _activityService = ActivityService();
  final FraudRepository _fraudRepository = FraudRepository(FirestoreService());

  String _selectedReportType = AppStrings.fakeProduct;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuthService().currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to submit a report')),
          );
          return;
        }

        // Create the fraud report
        final report = FraudReportModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          reporterId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedReportType,
          status: 'pending',
          isAnonymous: _isAnonymous,
          productId: widget.productId,
          vendorId: widget.vendorId,
          mediaUrls: [], // TODO: Add media upload
          severity: 3, // Default medium severity
          evidence: {}, // TODO: Add evidence collection
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save the report
        await _fraudRepository.createReport(report);

        // Create activity for the report
        await _activityService.createReportActivity(
          userId: user.uid,
          report: report,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.reportSubmitted)),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit report: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.fraudReport),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Report type
              Text(
                AppStrings.reportType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReportType,
                items: [
                  AppStrings.fakeProduct,
                  AppStrings.suspiciousVendor,
                  AppStrings.misleadingInfo,
                  AppStrings.other,
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReportType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Report Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              CustomTextField(
                controller: _descriptionController,
                label: AppStrings.description,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Attach evidence
              Text(
                AppStrings.attachEvidence,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement file/image picker
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Select Files'),
              ),
              const SizedBox(height: 24),
              // Anonymous option
              CheckboxListTile(
                title: const Text('Submit anonymously'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 32),
              // Submit button
              CustomButton(
                onPressed: _submitReport,
                text: AppStrings.submitReport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

