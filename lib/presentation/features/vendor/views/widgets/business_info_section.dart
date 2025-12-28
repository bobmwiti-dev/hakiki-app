import '../../../../../core/app_export.dart';

class BusinessInfoSection extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController registrationNumberController;
  final TextEditingController addressController;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final List<String> businessCategories;

  const BusinessInfoSection({
    super.key,
    required this.companyNameController,
    required this.registrationNumberController,
    required this.addressController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.businessCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Business Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          
          // Company Name
          _buildTextField(
            context,
            controller: companyNameController,
            label: 'Company Name',
            hint: 'Enter your registered company name',
            icon: 'business_center',
            isRequired: true,
          ),
          SizedBox(height: 2.h),
          
          // Registration Number
          _buildTextField(
            context,
            controller: registrationNumberController,
            label: 'Registration Number',
            hint: 'Enter business registration number',
            icon: 'assignment',
            isRequired: true,
          ),
          SizedBox(height: 2.h),
          
          // Business Category
          _buildCategoryDropdown(context),
          SizedBox(height: 2.h),
          
          // Business Address
          _buildTextField(
            context,
            controller: addressController,
            label: 'Business Address',
            hint: 'Enter complete business address',
            icon: 'location_on',
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(
                _getIconData(icon),
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.neutralBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surface,
          ),
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Business Category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              '*',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select your business category',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.category,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.neutralBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surface,
          ),
          items: businessCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: onCategoryChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a business category';
            }
            return null;
          },
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'business':
        return Icons.business;
      case 'location_on':
        return Icons.location_on;
      case 'description':
        return Icons.description;
      default:
        return Icons.help_outline;
    }
  }
}
