import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class ProductInformationSection extends StatelessWidget {
  final TextEditingController productNameController;
  final TextEditingController productBrandController;
  final TextEditingController productPriceController;
  final VoidCallback onScanToFill;

  const ProductInformationSection({
    super.key,
    required this.productNameController,
    required this.productBrandController,
    required this.productPriceController,
    required this.onScanToFill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: onScanToFill,
              icon: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
              label: Text(
                'Scan to Fill',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: productNameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            hintText: 'Enter product name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.shopping_bag,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Product name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: productBrandController,
          decoration: InputDecoration(
            labelText: 'Brand (Optional)',
            hintText: 'Enter brand name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.business,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: productPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price (Optional)',
            hintText: 'Enter price',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: const Icon(
                Icons.attach_money,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
