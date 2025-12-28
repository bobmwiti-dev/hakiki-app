import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class HeroIllustrationWidget extends StatefulWidget {
  const HeroIllustrationWidget({super.key});


  @override
  State<HeroIllustrationWidget> createState() => _HeroIllustrationWidgetState();
}


class _HeroIllustrationWidgetState extends State<HeroIllustrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late AnimationController _networkAnimationController;


  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();


    _networkAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }


  @override
  void dispose() {
    _scanAnimationController.dispose();
    _networkAnimationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background network visualization
          _buildNetworkBackground(),


          // Main illustration container
          _buildMainIllustration(),


          // Floating elements
          _buildFloatingElements(),


          // Verification checkmarks
          _buildVerificationCheckmarks(),
        ],
      ),
    );
  }


  Widget _buildNetworkBackground() {
    return AnimatedBuilder(
      animation: _networkAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: NetworkPainter(
            animationValue: _networkAnimationController.value,
            primaryColor: Theme.of(context).primaryColor,
          ),
          size: Size(double.infinity, 35.h),
        );
      },
    );
  }


  Widget _buildMainIllustration() {
    return Center(
      child: Container(
        width: 60.w,
        height: 25.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).primaryColor.withAlpha(13),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withAlpha(26),
              blurRadius: 30,
              spreadRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Phone mockup
            _buildPhoneMockup(),


            // Scanning animation
            _buildScanningAnimation(),
          ],
        ),
      ),
    );
  }


  Widget _buildPhoneMockup() {
    return Positioned(
      left: 12.w,
      top: 3.h,
      child: Container(
        width: 36.w,
        height: 19.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Screen content
            Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 8.w,
                      color: Colors.white,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Scan QR Code',
                      style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            // Scanning line animation
            AnimatedBuilder(
              animation: _scanAnimationController,
              builder: (context, child) {
                return Positioned(
                  left: 3.w,
                  top: 3.h + (_scanAnimationController.value * 13.h),
                  child: Container(
                    width: 30.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withAlpha(128),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildScanningAnimation() {
    return AnimatedBuilder(
      animation: _scanAnimationController,
      builder: (context, child) {
        return Positioned(
          right: 8.w,
          top: 4.h,
          child: Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // QR code pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: QRPatternPainter(),
                  ),
                ),


                // Scanning effect
                Positioned(
                  top: _scanAnimationController.value * 12.w,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 0.5,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Security icons
        Positioned(
          left: 5.w,
          top: 8.h,
          child: _buildFloatingIcon(
            Icons.security,
            Colors.green,
            0,
          ),
        ),
        Positioned(
          right: 8.w,
          bottom: 12.h,
          child: _buildFloatingIcon(
            Icons.verified_user,
            Colors.green,
            500,
          ),
        ),
        Positioned(
          left: 8.w,
          bottom: 6.h,
          child: _buildFloatingIcon(
            Icons.shield_outlined,
            Theme.of(context).primaryColor,
            1000,
          ),
        ),
      ],
    );
  }


  Widget _buildFloatingIcon(IconData icon, Color color, int delay) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withAlpha(77),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 4.w,
        color: color,
      ),
    );
  }


  Widget _buildVerificationCheckmarks() {
    return Stack(
      children: [
        Positioned(
          right: 15.w,
          top: 5.h,
          child: _buildCheckmark(0),
        ),
        Positioned(
          right: 12.w,
          top: 8.h,
          child: _buildCheckmark(200),
        ),
        Positioned(
          right: 18.w,
          top: 11.h,
          child: _buildCheckmark(400),
        ),
      ],
    );
  }


  Widget _buildCheckmark(int delay) {
    return Container(
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(77),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.check,
        size: 3.w,
        color: Colors.white,
      ),
    );
  }
}


class NetworkPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  NetworkPainter({
    required this.animationValue,
    required this.primaryColor,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withAlpha(26)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = primaryColor.withAlpha(51)
      ..style = PaintingStyle.fill;


    // Draw network nodes
    final nodes = <Offset>[
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
    ];


    // Draw connections between nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if ((nodes[i] - nodes[j]).distance < size.width * 0.6) {
          final opacity = (0.3 - (animationValue - 0.5).abs()) * 2;
          paint.color = Colors.blue.withValues(alpha: opacity.clamp(0.0, 0.2));
          canvas.drawLine(nodes[i], nodes[j], paint);
        }
      }
    }


    // Draw animated nodes
    for (final node in nodes) {
      final radius = 3 + sin(animationValue * 2 * pi).abs() * 2;
      canvas.drawCircle(node, radius, dotPaint);
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class QRPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;


    final cellSize = size.width / 5;


    // Create a simple QR-like pattern
    final pattern = [
      [1, 1, 1, 0, 1],
      [1, 0, 1, 1, 0],
      [1, 1, 0, 1, 1],
      [0, 1, 1, 0, 1],
      [1, 0, 1, 1, 0],
    ];


    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * cellSize,
              i * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
