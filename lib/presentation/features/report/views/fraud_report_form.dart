import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/report_viewmodel.dart';

class FraudReportForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const FraudReportForm({super.key, this.initialData});

  @override
  State<FraudReportForm> createState() => _FraudReportFormState();
}

class _FraudReportFormState extends State<FraudReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _productNameController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String _selectedType = 'counterfeit_product';
  int _selectedSeverity = 3;
  bool _isAnonymous = false;
  final List<XFile> _attachedMedia = [];

  final List<Map<String, String>> _reportTypes = [
    {'value': 'counterfeit_product', 'label': 'Counterfeit Product'},
    {'value': 'fake_vendor', 'label': 'Fake Vendor'},
    {'value': 'misleading_info', 'label': 'Misleading Information'},
    {'value': 'price_manipulation', 'label': 'Price Manipulation'},
    {'value': 'quality_issues', 'label': 'Quality Issues'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {'value': 1, 'label': 'Low', 'description': 'Minor issue, low impact'},
    {'value': 2, 'label': 'Medium', 'description': 'Moderate issue, some impact'},
    {'value': 3, 'label': 'High', 'description': 'Serious issue, high impact'},
    {'value': 4, 'label': 'Critical', 'description': 'Very serious issue, critical impact'},
    {'value': 5, 'label': 'Emergency', 'description': 'Urgent issue, immediate action required'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromData();
  }

  void _initializeFromData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _productNameController.text = data['productName'] ?? '';
      _vendorNameController.text = data['vendorName'] ?? '';
      _selectedType = data['type'] ?? 'counterfeit_product';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _productNameController.dispose();
    _vendorNameController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Fraud'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.report_problem, color: Theme.of(context).colorScheme.error, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Report Fraud or Suspicious Activity',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Help protect the community by reporting fraudulent products or vendors',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Report Type
                  Text(
                    'Report Type *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: _reportTypes.map((type) {
                          return RadioListTile<String>(
                            value: type['value']!,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                            title: Text(type['label']!),
                            activeColor: Theme.of(context).primaryColor,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Report Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Report Title *',
                      hintText: 'Brief summary of the issue',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a report title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Description *',
                      hintText: 'Provide detailed information about the fraud or issue',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a detailed description';
                      }
                      if (value.trim().length < 20) {
                        return 'Description must be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product Information (if applicable)
                  if (_selectedType == 'counterfeit_product' || _selectedType == 'quality_issues') ...[
                    Text(
                      'Product Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Name of the product in question',
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Vendor Information (if applicable)
                  if (_selectedType == 'fake_vendor' || _selectedType == 'misleading_info') ...[
                    Text(
                      'Vendor Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _vendorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor/Business Name',
                        hintText: 'Name of the vendor or business',
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (Optional)',
                      hintText: 'Where did this occur?',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Severity Level
                  Text(
                    'Severity Level *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: _severityLevels.map((severity) {
                          return RadioListTile<int>(
                            value: severity['value'] as int,
                            groupValue: _selectedSeverity,
                            onChanged: (value) {
                              setState(() {
                                _selectedSeverity = value!;
                              });
                            },
                            title: Text(severity['label']!),
                            subtitle: Text(severity['description']!),
                            activeColor: _getSeverityColor(severity['value']!),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Media Attachments
                  Text(
                    'Evidence (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Attach photos or videos as evidence to support your report',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Media Grid
                  if (_attachedMedia.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _attachedMedia.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _attachedMedia[index].path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image, size: 32),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachedMedia.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Add Media Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickMedia(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickMedia(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Information
                  TextFormField(
                    controller: _additionalInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Information (Optional)',
                      hintText: 'Any other relevant details...',
                      prefixIcon: Icon(Icons.info),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Anonymous Reporting
                  Card(
                    child: CheckboxListTile(
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value ?? false;
                        });
                      },
                      title: const Text('Submit Anonymously'),
                      subtitle: const Text(
                        'Your identity will be kept private. Note: Anonymous reports may take longer to process.',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Report'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer
                  Card(
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Important Notice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• False reports may result in account suspension\n'
                            '• All reports are reviewed by our moderation team\n'
                            '• You may be contacted for additional information\n'
                            '• Reports help improve platform security for everyone',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Error Display
                  if (viewModel.error != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.error!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (file != null) {
        setState(() {
          _attachedMedia.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking media: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ReportViewModel>();
    
    // Set the report data in the viewModel
    viewModel.setReportType(_selectedType);
    viewModel.setTitle(_titleController.text.trim());
    viewModel.setDescription(_descriptionController.text.trim());
    viewModel.setSeverity(_selectedSeverity);
    viewModel.setAnonymous(_isAnonymous);
    
    // Clear existing media and add new files
    viewModel.clearMedia();
    for (final xFile in _attachedMedia) {
      // Convert XFile to File
      final file = File(xFile.path);
      viewModel.addMediaFile(file);
    }
    
    final success = await viewModel.submitReport();

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 48),
          title: const Text('Report Submitted'),
          content: const Text(
            'Thank you for your report. Our moderation team will review it and take appropriate action. '
            'You will be notified of any updates.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
