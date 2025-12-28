import '../../../../core/app_export.dart';
import './widgets/bank_account_section.dart';
import './widgets/business_info_section.dart';
import './widgets/document_upload_section.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/tax_id_section.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form Controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _routingNumberController =
      TextEditingController();

  // Form State
  String? _selectedCategory;
  String _selectedCountry = '';
  final List<Map<String, dynamic>> _uploadedDocuments = [];
  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;

  // Mock Data
  final List<String> _businessCategories = [
    'Electronics & Gadgets',
    'Fashion & Apparel',
    'Home & Garden',
    'Sports & Outdoors',
    'Books & Media',
    'Health & Beauty',
    'Automotive Parts',
    'Toys & Games',
    'Food & Beverages',
    'Office Supplies',
    'Luxury Items',
    'Pharmaceuticals',
    'Designer Fashion',
    'Art & Collectibles',
    'Other',
  ];

  final List<String> _stepTitles = [
    'Business Info',
    'Documents',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _setupFormListeners();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFormListeners() {
    _companyNameController.addListener(_onFormChanged);
    _registrationNumberController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _taxIdController.addListener(_onFormChanged);
    _bankNameController.addListener(_onFormChanged);
    _accountNumberController.addListener(_onFormChanged);
    _routingNumberController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildStickyHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgressIndicatorWidget(
                          currentStep: 1,
                          totalSteps: 3,
                          stepTitles: _stepTitles,
                        ),
                        SizedBox(height: 3.h),
                        BusinessInfoSection(
                          companyNameController: _companyNameController,
                          registrationNumberController:
                              _registrationNumberController,
                          addressController: _addressController,
                          selectedCategory: _selectedCategory,
                          onCategoryChanged: _onCategoryChanged,
                          businessCategories: _businessCategories,
                        ),
                        SizedBox(height: 3.h),
                        DocumentUploadSection(
                          uploadedDocuments: _uploadedDocuments,
                          onDocumentAdded: _onDocumentAdded,
                          onDocumentRemoved: _onDocumentRemoved,
                        ),
                        SizedBox(height: 3.h),
                        TaxIdSection(
                          taxIdController: _taxIdController,
                          selectedCountry: _selectedCountry,
                          onCountryChanged: _onCountryChanged,
                        ),
                        SizedBox(height: 3.h),
                        BankAccountSection(
                          bankNameController: _bankNameController,
                          accountNumberController: _accountNumberController,
                          routingNumberController: _routingNumberController,
                          isOptional: true,
                        ),
                        SizedBox(height: 4.h),
                        _buildSubmitButton(),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: const Border(
          bottom: BorderSide(
            color: AppTheme.neutralBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _onBackPressed(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.neutralBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppTheme.textHighEmphasisLight,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Become Verified Vendor',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textHighEmphasisLight,
                  ),
                ),
                Text(
                  'Build trust with verified business credentials',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_hasUnsavedChanges)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Unsaved',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 10.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isFormValid = _isFormComplete();

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isFormValid && !_isSubmitting ? _submitForReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFormValid ? AppTheme.primaryBlue : AppTheme.neutralBorder,
          foregroundColor: isFormValid ? Colors.white : AppTheme.textSecondary,
          elevation: isFormValid ? 2 : 0,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Submitting...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send,
                    color: isFormValid ? Colors.white : AppTheme.textSecondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Submit for Review',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _hasUnsavedChanges = true;
    });
  }

  void _onCountryChanged(String country) {
    setState(() {
      _selectedCountry = country;
      _hasUnsavedChanges = true;
    });
  }

  void _onDocumentAdded(Map<String, dynamic> document) {
    setState(() {
      _uploadedDocuments.add(document);
      _hasUnsavedChanges = true;
    });
  }

  void _onDocumentRemoved(int index) {
    setState(() {
      _uploadedDocuments.removeAt(index);
      _hasUnsavedChanges = true;
    });
  }

  bool _isFormComplete() {
    return _companyNameController.text.trim().isNotEmpty &&
        _registrationNumberController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _taxIdController.text.trim().isNotEmpty &&
        _selectedCountry.isNotEmpty &&
        _uploadedDocuments.isNotEmpty;
  }

  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('Please fill in all required fields correctly');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 3));

      // Show success and navigate
      _showSuccessDialog();

      setState(() {
        _hasUnsavedChanges = false;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showErrorMessage('Failed to submit application. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successAccent,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Application Submitted',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your vendor application is now under review.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Timeline:',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '• Document verification: 2-3 business days\n• Background check: 3-5 business days\n• Final approval: 1-2 business days',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue to Dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.warningColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Unsaved Changes',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
          ],
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textHighEmphasisLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _onBackPressed() async {
    final navigator = Navigator.of(context);
    final shouldPop = await _onWillPop();
    if (shouldPop && mounted) {
      navigator.pop();
    }
  }
}
