import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class UrgencyLevelSelector extends StatelessWidget {
  final String selectedUrgency;
  final Function(String) onUrgencySelected;

  const UrgencyLevelSelector({
    super.key,
    required this.selectedUrgency,
    required this.onUrgencySelected,
  });

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return const Color(0xFF8B0000); // Dark red
      default:
        return Colors.black54;
    }
  }


  IconData _getUrgencyIconData(String urgency) {
    switch (urgency) {
      case 'Low':
        return Icons.info;
      case 'Medium':
        return Icons.warning;
      case 'High':
        return Icons.error;
      case 'Critical':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  String _getUrgencyDescription(String urgency) {
    switch (urgency) {
      case 'Low':
        return 'Minor issue, standard processing time';
      case 'Medium':
        return 'Moderate concern, expedited review';
      case 'High':
        return 'Serious issue, priority handling';
      case 'Critical':
        return 'Immediate threat, urgent response required';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Select the urgency level based on the severity of the incident',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: urgencyLevels.map((urgency) {
            final bool isSelected = selectedUrgency == urgency;
            final Color urgencyColor = _getUrgencyColor(urgency);

            return GestureDetector(
              onTap: () => onUrgencySelected(urgency),
              child: Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? urgencyColor.withValues(alpha:0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? urgencyColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha:0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getUrgencyIconData(urgency),
                        color: urgencyColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            urgency,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? urgencyColor
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            _getUrgencyDescription(urgency),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: urgencyColor,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
