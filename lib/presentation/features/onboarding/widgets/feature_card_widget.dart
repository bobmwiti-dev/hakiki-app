import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';


class FeatureCardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;


  const FeatureCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });


  @override
  State<FeatureCardWidget> createState() => _FeatureCardWidgetState();
}


class _FeatureCardWidgetState extends State<FeatureCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;


  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );


    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }


  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }


  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }


  void _onTapCancel() {
    _scaleController.reverse();
  }


  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? colorScheme.primaryContainer.withAlpha(26)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isActive
                      ? colorScheme.primary.withAlpha(77)
                      : colorScheme.outline.withAlpha(51),
                  width: widget.isActive ? 2 : 1,
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(38),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: colorScheme.shadow.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature image
                  Container(
                    height: 25.h,
                    width: double.infinity,
                    margin: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Background image
                          CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  widget.icon,
                                  size: 15.w,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),


                          // Overlay gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  colorScheme.surface.withAlpha(26),
                                  colorScheme.surface.withAlpha(204),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),


                          // Feature icon overlay
                          Positioned(
                            top: 3.w,
                            right: 3.w,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withAlpha(51),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                size: 5.w,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),


                          // Interactive overlay
                          if (widget.isActive)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.primary.withAlpha(153),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withAlpha(230),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          size: 4.w,
                                          color: colorScheme.onPrimary,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Tap for demo',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),


                  // Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),


                        SizedBox(height: 0.5.h),


                        // Subtitle
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),


                        SizedBox(height: 2.h),


                        // Description
                        Text(
                          widget.description,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),


                        SizedBox(height: 3.h),


                        // Interactive hint
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isActive
                                ? colorScheme.primaryContainer.withAlpha(77)
                                : colorScheme.surfaceContainerHighest.withAlpha(77),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isActive
                                  ? colorScheme.primary.withAlpha(77)
                                  : colorScheme.outline.withAlpha(51),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isActive
                                    ? Icons.play_circle_outline
                                    : Icons.info_outline,
                                size: 4.w,
                                color: widget.isActive
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                widget.isActive
                                    ? 'Tap to see demo'
                                    : 'Swipe to explore',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: widget.isActive
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
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
            ),
          ),
        );
      },
    );
  }
}
