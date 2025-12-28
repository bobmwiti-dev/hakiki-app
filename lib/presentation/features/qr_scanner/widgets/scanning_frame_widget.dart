import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class ScanningFrameWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onTap;

  const ScanningFrameWidget({
    super.key,
    required this.isScanning,
    this.onTap,
  });

  @override
  State<ScanningFrameWidget> createState() => _ScanningFrameWidgetState();
}

class _ScanningFrameWidgetState extends State<ScanningFrameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScanningFrameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 60.w,
        height: 60.w,
        child: Stack(
          children: [
            // Scanning frame corners
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner(
                topLeft: true,
                color: widget.isScanning
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner(
                topRight: true,
                color: widget.isScanning
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCorner(
                bottomLeft: true,
                color: widget.isScanning
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCorner(
                bottomRight: true,
                color: widget.isScanning
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.outline,
              ),
            ),

            // Animated scanning line
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    top: _animation.value * (60.w - 4),
                    left: 4.w,
                    right: 4.w,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Theme.of(context).primaryColor,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor
                                .withAlpha(128),
                            blurRadius: 4,
                            spreadRadius: 1,
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

  Widget _buildCorner({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required Color color,
  }) {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: CustomPaint(
        painter: CornerPainter(
          color: color,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Color color;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  CornerPainter({
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLength = size.width * 0.6;

    if (topLeft) {
      canvas.drawLine(Offset(0, cornerLength), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    }

    if (topRight) {
      canvas.drawLine(
          Offset(size.width - cornerLength, 0), Offset(size.width, 0), paint);
      canvas.drawLine(
          Offset(size.width, 0), Offset(size.width, cornerLength), paint);
    }

    if (bottomLeft) {
      canvas.drawLine(
          Offset(0, size.height - cornerLength), Offset(0, size.height), paint);
      canvas.drawLine(
          Offset(0, size.height), Offset(cornerLength, size.height), paint);
    }

    if (bottomRight) {
      canvas.drawLine(Offset(size.width, size.height - cornerLength),
          Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height),
          Offset(size.width - cornerLength, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
