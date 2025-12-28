import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class AnonymousReportingToggle extends StatelessWidget {
  final bool isAnonymous;
  final Function(bool) onToggle;

  const AnonymousReportingToggle({
    super.key,
    required this.isAnonymous,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Anonymous Reporting',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              value: isAnonymous,
              onChanged: onToggle,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isAnonymous
                ? Colors.orange.withValues(alpha:0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAnonymous ? Colors.orange : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAnonymous ? Icons.visibility_off : Icons.visibility,
                    color: isAnonymous ? Colors.orange : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    isAnonymous ? 'Anonymous Report' : 'Identified Report',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isAnonymous ? Colors.orange : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                isAnonymous
                    ? '• Your identity will be hidden from the report\n• Authorities cannot contact you for follow-up\n• May limit investigation effectiveness\n• Report tracking will be limited'
                    : '• Your identity will be included in the report\n• Authorities can contact you for additional information\n• Enables more thorough investigation\n• Full report tracking and updates available',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
