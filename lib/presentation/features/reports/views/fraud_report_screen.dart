import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../widgets/anonymous_reporting_toggle.dart';
import '../widgets/description_text_area.dart';
import '../widgets/evidence_upload_area.dart';
import '../widgets/incident_type_selector.dart';
import '../widgets/location_services_section.dart';
import '../widgets/product_information_section.dart';
import '../widgets/seller_information_section.dart';
import '../widgets/urgency_level_selector.dart';

class FraudReportScreen extends StatefulWidget {
  const FraudReportScreen({super.key});

  @override
  State<FraudReportScreen> createState() => _FraudReportScreenState();
}

class _FraudReportScreenState extends State<FraudReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productBrandController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _platformController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();
  final TextEditingController _listingUrlController = TextEditingController();

  // Form state
  String _selectedIncidentType = '';
  String _selectedUrgency = 'Medium';
  bool _isLocationEnabled = false;
  String? _currentLocation;
  bool _isAnonymous = false;
  List<XFile> _selectedFiles = [];
  bool _isSubmitting = false;

  // Mock data for auto-save functionality
  final Map<String, dynamic> _draftData = {};

  @override
  void initState() {
    super.initState();
    _loadDraftData();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productBrandController.dispose();
    _productPriceController.dispose();
    _descriptionController.dispose();
    _platformController.dispose();
    _sellerNameController.dispose();
    _listingUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDraftData() {
    // Simulate loading draft data
    setState(() {
      _selectedIncidentType = _draftData['incidentType'] ?? '';
      _selectedUrgency = _draftData['urgency'] ?? 'Medium';
      _isLocationEnabled = _draftData['locationEnabled'] ?? false;
      _currentLocation = _draftData['location'];
      _isAnonymous = _draftData['anonymous'] ?? false;
    });
  }

  void _setupAutoSave() {
    // Auto-save every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _saveDraft();
        _setupAutoSave();
      }
    });
  }

  void _saveDraft() {
    _draftData.addAll({
      'incidentType': _selectedIncidentType,
      'productName': _productNameController.text,
      'productBrand': _productBrandController.text,
      'productPrice': _productPriceController.text,
      'description': _descriptionController.text,
      'platform': _platformController.text,
      'sellerName': _sellerNameController.text,
      'listingUrl': _listingUrlController.text,
      'urgency': _selectedUrgency,
      'locationEnabled': _isLocationEnabled,
      'location': _currentLocation,
      'anonymous': _isAnonymous,
      'lastSaved': DateTime.now().toIso8601String(),
    });
  }

  void _onScanToFill() {
    Navigator.pushNamed(context, '/qr-code-scanner').then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _productNameController.text = result['productName'] ?? '';
          _productBrandController.text = result['brand'] ?? '';
          _productPriceController.text = result['price']?.toString() ?? '';
        });
      }
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedIncidentType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an incident type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call with file upload progress
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock report ID
      final reportId =
          'FR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      // Clear draft data on successful submission
      _draftData.clear();

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Show success dialog
      _showSuccessDialog(reportId);
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit report. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog(String reportId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Report Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your fraud report has been successfully submitted.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report ID: $reportId',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Expected Response Time: ${_getExpectedResponseTime()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'You will receive updates on your report via ${_isAnonymous ? 'the app notifications' : 'email and app notifications'}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home-dashboard');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _getExpectedResponseTime() {
    switch (_selectedUrgency) {
      case 'Critical':
        return '1-2 hours';
      case 'High':
        return '4-6 hours';
      case 'Medium':
        return '24-48 hours';
      case 'Low':
        return '3-5 business days';
      default:
        return '24-48 hours';
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges()) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Save Draft?'),
              content: const Text(
                  'You have unsaved changes. Would you like to save them as a draft?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () {
                    _saveDraft();
                    Navigator.pop(context, true);
                  },
                  child: const Text('Save Draft'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Continue Editing'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  bool _hasUnsavedChanges() {
    return _productNameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _platformController.text.isNotEmpty ||
        _sellerNameController.text.isNotEmpty ||
        _selectedIncidentType.isNotEmpty ||
        _selectedFiles.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = Navigator.of(context);
          final shouldPop = await _onWillPop();
          if (!mounted) return;
          if (shouldPop && mounted) {
            navigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Report Fraud'),
          leading: IconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final shouldPop = await _onWillPop();
              if (!mounted) return;
              if (shouldPop && mounted) {
                navigator.pop();
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 24,
            ),
          ),
          actions: [
            if (_draftData.isNotEmpty)
              TextButton(
                onPressed: _saveDraft,
                child: Text(
                  'Save Draft',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Fill out the form below to report fraudulent activity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Incident Type Selector
                      IncidentTypeSelector(
                        selectedType: _selectedIncidentType,
                        onTypeSelected: (type) {
                          setState(() => _selectedIncidentType = type);
                        },
                      ),
                      SizedBox(height: 4.h),

                      // Product Information Section
                      ProductInformationSection(
                        productNameController: _productNameController,
                        productBrandController: _productBrandController,
                        productPriceController: _productPriceController,
                        onScanToFill: _onScanToFill,
                      ),
                      SizedBox(height: 4.h),

                      // Description Text Area
                      DescriptionTextArea(
                        controller: _descriptionController,
                      ),
                      SizedBox(height: 4.h),

                      // Evidence Upload Area
                      EvidenceUploadArea(
                        selectedFiles: _selectedFiles,
                        onFilesSelected: (files) {
                          setState(() => _selectedFiles = files);
                        },
                      ),
                      SizedBox(height: 4.h),

                      // Location Services Section
                      LocationServicesSection(
                        isLocationEnabled: _isLocationEnabled,
                        onLocationToggle: (enabled) {
                          setState(() => _isLocationEnabled = enabled);
                        },
                        currentLocation: _currentLocation,
                        onLocationUpdate: (location) {
                          setState(() => _currentLocation = location);
                        },
                      ),
                      SizedBox(height: 4.h),

                      // Seller Information Section
                      SellerInformationSection(
                        platformController: _platformController,
                        sellerNameController: _sellerNameController,
                        listingUrlController: _listingUrlController,
                      ),
                      SizedBox(height: 4.h),

                      // Urgency Level Selector
                      UrgencyLevelSelector(
                        selectedUrgency: _selectedUrgency,
                        onUrgencySelected: (urgency) {
                          setState(() => _selectedUrgency = urgency);
                        },
                      ),
                      SizedBox(height: 4.h),

                      // Anonymous Reporting Toggle
                      AnonymousReportingToggle(
                        isAnonymous: _isAnonymous,
                        onToggle: (anonymous) {
                          setState(() => _isAnonymous = anonymous);
                        },
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Submitting Report...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Submit Report',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
