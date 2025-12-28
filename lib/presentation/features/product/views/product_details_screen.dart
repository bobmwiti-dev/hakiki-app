import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/app_export.dart';
import '../../verify/viewmodels/verify_viewmodel.dart';
import '../../report/views/fraud_report_form.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final String scannedCode;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.scannedCode,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  VendorModel? vendor;
  bool isLoadingVendor = true;

  @override
  void initState() {
    super.initState();
    _loadVendorDetails();
  }

  Future<void> _loadVendorDetails() async {
    try {
      final viewModel = context.read<VerifyViewModel>();
      final vendorData = await viewModel.getVendorDetails(widget.product.vendorId);
      if (mounted) {
        setState(() {
          vendor = vendorData;
          isLoadingVendor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingVendor = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Verification'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shareProduct,
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Report Issue'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'report') {
                _reportProduct();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification Status Banner
            _buildVerificationBanner(),
            
            // Product Images
            _buildProductImages(),
            
            // Product Information
            _buildProductInfo(),
            
            // Vendor Information
            _buildVendorInfo(),
            
            // Trust Score & Verification Details
            _buildTrustDetails(),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    final isVerified = widget.product.isVerified;
    final isFlagged = widget.product.reportCount > 0;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    if (isFlagged) {
      backgroundColor = AppTheme.errorColor;
      textColor = Colors.white;
      icon = Icons.warning;
      title = 'FLAGGED PRODUCT';
      subtitle = 'This product has been flagged as potentially fraudulent';
    } else if (isVerified) {
      backgroundColor = AppTheme.successColor;
      textColor = Colors.white;
      icon = Icons.verified;
      title = 'VERIFIED AUTHENTIC';
      subtitle = 'This product has been verified as genuine';
    } else {
      backgroundColor = AppTheme.warningColor;
      textColor = Colors.white;
      icon = Icons.help;
      title = 'VERIFICATION PENDING';
      subtitle = 'Product verification is in progress';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.withAlpha(153),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImages() {
    return SizedBox(
      height: 300,
      child: widget.product.imageUrls.isEmpty
          ? Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No images available'),
                  ],
                ),
              ),
            )
          : PageView.builder(
              itemCount: widget.product.imageUrls.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.product.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error, size: 64, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          
          // Product Details Grid
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Product Code', widget.scannedCode),
                  _buildDetailRow('Category', widget.product.category),
                  _buildDetailRow('Brand', widget.product.brand),
                  _buildDetailRow('Price', '\$${widget.product.price.toStringAsFixed(2)}'),
                  _buildDetailRow('Created Date', 
                    widget.product.createdAt.toString().split(' ')[0]),
                  _buildDetailRow('Last Updated', 
                    widget.product.updatedAt.toString().split(' ')[0]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Vendor Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (isLoadingVendor)
                const Center(child: CircularProgressIndicator())
              else if (vendor != null) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      vendor!.businessName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(vendor!.businessName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${vendor!.businessType}'),
                      Text('Trust Score: ${vendor!.trustScore}/100'),
                    ],
                  ),
                  trailing: _buildVerificationBadge(vendor!.verificationStatus),
                ),
                if (vendor!.businessWebsite != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchUrl(vendor!.businessWebsite!),
                    child: Row(
                      children: [
                        Icon(Icons.web, size: 16, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          vendor!.businessWebsite!,
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else
                const Text('Vendor information not available'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Trust & Security',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Trust Score
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Product Trust Score'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: widget.product.averageRating / 5,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(widget.product.averageRating * 20).toInt()}/100',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Verification Details
              _buildDetailRow('Verification Status', widget.product.isVerified ? 'Verified' : 'Not Verified'),
              _buildDetailRow('Last Updated', 
                widget.product.updatedAt.toString().split(' ')[0]),
              _buildDetailRow('Total Verifications', widget.product.verificationCount.toString()),
              _buildDetailRow('Reports Count', '${widget.product.reportCount}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scanAnother,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reportProduct,
                  icon: const Icon(Icons.report),
                  label: const Text('Report Issue'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _saveToHistory,
              icon: const Icon(Icons.bookmark),
              label: const Text('Save to History'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
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

  Widget _buildVerificationBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'approved':
        color = AppTheme.successColor;
        icon = Icons.verified;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        icon = Icons.pending;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(153),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _shareProduct() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing functionality coming soon!')),
    );
  }

  void _reportProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FraudReportForm(
          initialData: {
            'type': 'product_issue',
            'productId': widget.product.id,
            'productName': widget.product.name,
            'scannedCode': widget.scannedCode,
          },
        ),
      ),
    );
  }

  void _scanAnother() {
    Navigator.pop(context);
  }

  void _saveToHistory() {
    final viewModel = context.read<VerifyViewModel>();
    viewModel.saveToScanHistory(widget.product, widget.scannedCode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product saved to scan history'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _launchUrl(String url) {
    // Implement URL launching
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $url')),
    );
  }
}
