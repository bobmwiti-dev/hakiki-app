
import '../../../../../core/app_export.dart';

class TaxIdSection extends StatelessWidget {
  final TextEditingController taxIdController;
  final String selectedCountry;
  final Function(String) onCountryChanged;

  const TaxIdSection({
    super.key,
    required this.taxIdController,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  static const List<String> _countries = [
    'Kenya',
    'Uganda',
    'Tanzania',
    'Rwanda',
    'Burundi',
    'South Sudan',
    'Ethiopia',
    'Somalia',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Tax Information',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textHighEmphasisLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          
          // Country Selection
          _buildCountryDropdown(),
          SizedBox(height: 2.h),
          
          // Tax ID Field
          _buildTaxIdField(),
          SizedBox(height: 2.h),
          
          // Info Container
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax ID Requirements',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '• Kenya: KRA PIN (e.g., P051234567A)\n'
                        '• Uganda: TIN (Tax Identification Number)\n'
                        '• Tanzania: TIN (Taxpayer Identification Number)\n'
                        '• Other countries: Equivalent tax registration number',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Country of Registration',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
          value: selectedCountry.isEmpty ? null : selectedCountry,
          decoration: InputDecoration(
            hintText: 'Select country',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.flag,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: _countries.map((country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(country),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCountryChanged(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your country';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTaxIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tax ID / PIN Number',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
        TextFormField(
          controller: taxIdController,
          decoration: InputDecoration(
            hintText: _getTaxIdHint(),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.receipt,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Tax ID is required';
            }
            if (selectedCountry == 'Kenya' && !_isValidKenyaPin(value)) {
              return 'Invalid Kenya PIN format (e.g., P051234567A)';
            }
            return null;
          },
        ),
      ],
    );
  }

  String _getTaxIdHint() {
    switch (selectedCountry) {
      case 'Kenya':
        return 'Enter KRA PIN (e.g., P051234567A)';
      case 'Uganda':
        return 'Enter TIN number';
      case 'Tanzania':
        return 'Enter TIN number';
      default:
        return 'Enter tax identification number';
    }
  }

  bool _isValidKenyaPin(String pin) {
    // Basic Kenya PIN validation: starts with P, followed by 9 digits, ends with letter
    final regex = RegExp(r'^P\d{9}[A-Z]$');
    return regex.hasMatch(pin.toUpperCase());
  }
}
