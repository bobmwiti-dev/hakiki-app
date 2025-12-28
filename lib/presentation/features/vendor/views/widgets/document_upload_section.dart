
import '../../../../../core/app_export.dart';

class DocumentUploadSection extends StatelessWidget {
  final List<Map<String, dynamic>> uploadedDocuments;
  final Function(Map<String, dynamic>) onDocumentAdded;
  final Function(int) onDocumentRemoved;

  const DocumentUploadSection({
    super.key,
    required this.uploadedDocuments,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
  });

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
                Icons.upload_file,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Required Documents',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textHighEmphasisLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          Text(
            'Upload the following documents to verify your business:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          
          // Required Documents List
          _buildDocumentRequirement(
            'Business License',
            'Official business registration certificate',
            'description',
            true,
          ),
          SizedBox(height: 2.h),
          
          _buildDocumentRequirement(
            'Tax Certificate',
            'Tax registration or VAT certificate',
            'receipt_long',
            true,
          ),
          SizedBox(height: 2.h),
          
          _buildDocumentRequirement(
            'Owner ID Document',
            'National ID, passport, or driver\'s license',
            'badge',
            true,
          ),
          SizedBox(height: 2.h),
          
          _buildDocumentRequirement(
            'Bank Statement',
            'Recent business bank statement (optional)',
            'account_balance',
            false,
          ),
          SizedBox(height: 3.h),
          
          // Upload Area
          _buildUploadArea(context),
          
          // Uploaded Documents List
          if (uploadedDocuments.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Uploaded Documents',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
            SizedBox(height: 2.h),
            ...uploadedDocuments.asMap().entries.map((entry) {
              final index = entry.key;
              final document = entry.value;
              return _buildUploadedDocumentItem(document, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentRequirement(
    String title,
    String description,
    String icon,
    bool isRequired,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.neutralBorder.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.neutralBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isRequired 
                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                  : AppTheme.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getIconData(icon),
              color: isRequired ? AppTheme.primaryBlue : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleDocumentUpload(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload,
                color: AppTheme.primaryBlue,
                size: 32,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Upload Documents',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Tap to select files from your device',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Choose Files',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedDocumentItem(Map<String, dynamic> document, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.successAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.successAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.successAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.insert_drive_file,
              color: AppTheme.successAccent,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document['name'] ?? 'Document',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textHighEmphasisLight,
                  ),
                ),
                Text(
                  document['type'] ?? 'PDF Document',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onDocumentRemoved(index),
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.delete,
                color: AppTheme.errorColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDocumentUpload() {
    // Mock document upload - in real implementation, use file_picker
    final mockDocument = {
      'name': 'business_license_${uploadedDocuments.length + 1}.pdf',
      'type': 'PDF Document',
      'size': '2.4 MB',
      'uploadDate': DateTime.now().toIso8601String(),
    };
    
    onDocumentAdded(mockDocument);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'business':
        return Icons.business;
      case 'description':
        return Icons.description;
      case 'account_balance':
        return Icons.account_balance;
      case 'receipt':
        return Icons.receipt;
      default:
        return Icons.help_outline;
    }
  }
}
