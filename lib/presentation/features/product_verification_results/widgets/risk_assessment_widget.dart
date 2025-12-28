import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RiskAssessmentWidget extends StatefulWidget {
  final List<Map<String, dynamic>> riskIndicators;

  const RiskAssessmentWidget({
    super.key,
    required this.riskIndicators,
  });

  @override
  State<RiskAssessmentWidget> createState() => _RiskAssessmentWidgetState();
}

class _RiskAssessmentWidgetState extends State<RiskAssessmentWidget> {
  final Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    if (widget.riskIndicators.isEmpty) {
      return const SizedBox.shrink();
    }

    final highRiskCount = widget.riskIndicators
        .where((risk) => (risk['severity'] as String?) == 'high')
        .length;
    final mediumRiskCount = widget.riskIndicators
        .where((risk) => (risk['severity'] as String?) == 'medium')
        .length;
    final lowRiskCount = widget.riskIndicators
        .where((risk) => (risk['severity'] as String?) == 'low')
        .length;

    Color overallRiskColor;
    String overallRiskLevel;
    if (highRiskCount > 0) {
      overallRiskColor = Colors.red;
      overallRiskLevel = 'High Risk';
    } else if (mediumRiskCount > 0) {
      overallRiskColor = Colors.orange;
      overallRiskLevel = 'Medium Risk';
    } else {
      overallRiskColor = Colors.green;
      overallRiskLevel = 'Low Risk';
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: overallRiskColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.security,
                  color: overallRiskColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Assessment',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      overallRiskLevel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: overallRiskColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRiskCounter('High', highRiskCount, Colors.red),
                _buildRiskCounter('Medium', mediumRiskCount, Colors.orange),
                _buildRiskCounter('Low', lowRiskCount, Colors.green),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Risk Indicators',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.riskIndicators.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final risk = widget.riskIndicators[index];
              final severity = risk['severity'] as String? ?? 'low';
              final isExpanded = _expandedItems.contains(index);

              Color severityColor;
              IconData severityIcon;
              switch (severity) {
                case 'high':
                  severityColor = Colors.red;
                  severityIcon = Icons.error;
                  break;
                case 'medium':
                  severityColor = Colors.orange;
                  severityIcon = Icons.warning;
                  break;
                case 'low':
                default:
                  severityColor = Colors.green;
                  severityIcon = Icons.info;
                  break;
              }

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: severityColor.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedItems.remove(index);
                          } else {
                            _expandedItems.add(index);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(
                                color: severityColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                severityIcon,
                                color: severityColor,
                                size: 4.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    risk['title'] as String? ?? 'Unknown Risk',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    severity.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: severityColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 5.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Details:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              risk['description'] as String? ??
                                  'No additional details available.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            if (risk['recommendation'] != null) ...[
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: Theme.of(context).primaryColor,
                                      size: 3.5.w,
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        risk['recommendation'] as String,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context).primaryColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCounter(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
