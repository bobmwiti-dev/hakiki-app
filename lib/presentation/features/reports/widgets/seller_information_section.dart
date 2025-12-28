import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SellerInformationSection extends StatelessWidget {
  final TextEditingController platformController;
  final TextEditingController sellerNameController;
  final TextEditingController listingUrlController;

  const SellerInformationSection({
    super.key,
    required this.platformController,
    required this.sellerNameController,
    required this.listingUrlController,
  });

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: platformController,
          decoration: InputDecoration(
            labelText: 'Marketplace Platform',
            hintText: 'e.g., Amazon, eBay, Facebook Marketplace',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.store,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Platform is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: sellerNameController,
          decoration: InputDecoration(
            labelText: 'Seller Name/Username',
            hintText: 'Enter seller name or username',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.person,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Seller name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: listingUrlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: 'Listing URL (Optional)',
            hintText: 'https://example.com/product',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.link,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value != null &&
                value.trim().isNotEmpty &&
                !_isValidUrl(value.trim())) {
              return 'Please enter a valid URL';
            }
            return null;
          },
        ),
      ],
    );
  }
}
