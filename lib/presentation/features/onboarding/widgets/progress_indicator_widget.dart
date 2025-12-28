import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class OnboardingProgressIndicatorWidget extends StatefulWidget {
  final int currentStep;
  final int totalSteps;


  const OnboardingProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });


  @override
  State<OnboardingProgressIndicatorWidget> createState() =>
      _OnboardingProgressIndicatorWidgetState();
}


class _OnboardingProgressIndicatorWidgetState
    extends State<OnboardingProgressIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;


  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );


    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentStep / widget.totalSteps,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));


    _progressController.forward();
  }


  @override
  void didUpdateWidget(OnboardingProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.currentStep / widget.totalSteps,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ));


      _progressController.reset();
      _progressController.forward();
    }
  }


  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step text
        Text(
          'Step ${widget.currentStep} of ${widget.totalSteps}',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),


        SizedBox(height: 1.h),


        // Progress bar container
        Container(
          width: 20.w,
          height: 0.6.h,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),


        SizedBox(height: 0.5.h),


        // Dots indicator
        Row(
          children: List.generate(
            widget.totalSteps,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 1.w),
              width: index < widget.currentStep ? 2.w : 1.5.w,
              height: index < widget.currentStep ? 2.w : 1.5.w,
              decoration: BoxDecoration(
                color: index < widget.currentStep
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(77),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
