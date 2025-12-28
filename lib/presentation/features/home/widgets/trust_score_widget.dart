import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TrustScoreWidget extends StatelessWidget {
  final int trustScore;
  final String trustLevel;
  final List<String> improvementTips;

  const TrustScoreWidget({
    super.key,
    required this.trustScore,
    required this.trustLevel,
    required this.improvementTips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              Icon(
                Icons.security,
                color: Theme.of(context).primaryColor,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                "Trust Score",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$trustScore",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getTrustScoreColor(),
                        fontSize: 32.sp,
                      ),
                    ),
                    Text(
                      trustLevel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _getTrustScoreColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      width: double.infinity,
                      height: 1.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(0.5.h),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: trustScore / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getTrustScoreColor(),
                            borderRadius: BorderRadius.circular(0.5.h),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Improve Your Score",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ...improvementTips
                        .take(3)
                        .map((tip) => Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 1.5.w,
                                    height: 1.5.w,
                                    margin: EdgeInsets.only(top: 1.h),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 11.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        ,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTrustScoreColor() {
    if (trustScore >= 80) return Colors.green;
    if (trustScore >= 60) return Colors.orange;
    return Colors.red;
  }
}
