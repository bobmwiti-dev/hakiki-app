import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';
import '../widgets/feature_card_widget.dart';
import '../widgets/progress_indicator_widget.dart';

class OnboardingFeaturesScreen extends StatefulWidget {
  const OnboardingFeaturesScreen({super.key});

  @override
  State<OnboardingFeaturesScreen> createState() =>
      _OnboardingFeaturesScreenState();
}

class _OnboardingFeaturesScreenState extends State<OnboardingFeaturesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;

  final PageController _pageController = PageController();
  int _currentFeature = 0;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'QR Code Scanning',
      'subtitle': 'Instant Product Verification',
      'description':
          'Scan any product QR code to instantly verify its authenticity. Our camera overlay provides real-time guidance with successful verification flow and fraud detection.',
      'imageUrl':
          'https://images.unsplash.com/photo-1516905365385-7f62e7e88245?w=600&h=400&fit=crop&crop=center',
      'icon': Icons.qr_code_scanner,
      'demoActions': [
        'Tap to activate camera',
        'Point at QR code',
        'Get instant results',
        'View trust score',
      ],
    },
    {
      'title': 'Community Reporting',
      'subtitle': 'Protect Others from Fraud',
      'description':
          'Report suspicious products and fraudulent sellers to help build a safer marketplace. Submit evidence, location data, and detailed descriptions to protect the community.',
      'imageUrl':
          'https://images.unsplash.com/photo-1573164713714-d95e436ab8d6?w=600&h=400&fit=crop&crop=center',
      'icon': Icons.report_outlined,
      'demoActions': [
        'Select incident type',
        'Upload evidence photos',
        'Add location details',
        'Submit fraud alert',
      ],
    },
    {
      'title': 'Vendor Verification',
      'subtitle': 'Trust Authentic Sellers',
      'description':
          'Verify legitimate businesses through our comprehensive authentication workflow. Check business credentials, certifications, and community trust ratings.',
      'imageUrl':
          'https://images.unsplash.com/photo-1560472355-536de3962603?w=600&h=400&fit=crop&crop=center',
      'icon': Icons.verified_user,
      'demoActions': [
        'Search vendor database',
        'View verification status',
        'Check trust rating',
        'Read community reviews',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    _slideController.forward();
  }

  void _nextFeature() {
    if (_currentFeature < _features.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentFeature++;
      });
      _pageController.animateToPage(
        _currentFeature,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTour();
    }
  }

  void _previousFeature() {
    if (_currentFeature > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentFeature--;
      });
      _pageController.animateToPage(
        _currentFeature,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipTour() {
    HapticFeedback.lightImpact();
    _completeTour();
  }

  void _completeTour() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _onFeatureTap(int index) {
    HapticFeedback.selectionClick();
    // Mini-demonstration of feature
    _showFeatureDemo(index);
  }

  void _showFeatureDemo(int index) {
    final feature = _features[index];
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                feature['icon'],
                size: 12.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                '${feature['title']} Demo',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              ...List.generate(
                feature['demoActions'].length,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          feature['demoActions'][i],
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return SlideTransition(
                  position: _headerSlideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Progress indicator
                        const OnboardingProgressIndicatorWidget(
                          currentStep: 2,
                          totalSteps: 3,
                        ),

                        // Skip tour button
                        TextButton(
                          onPressed: _skipTour,
                          child: Text(
                            'Skip Tour',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Title
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      children: [
                        Text(
                          'Core Features',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Discover how Hakiki protects you from fraud',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 4.h),

            // Feature cards
            Expanded(
              child: AnimatedBuilder(
                animation: _slideController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _contentSlideAnimation,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentFeature = index;
                        });
                      },
                      itemCount: _features.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: FeatureCardWidget(
                            title: _features[index]['title'],
                            subtitle: _features[index]['subtitle'],
                            description: _features[index]['description'],
                            imageUrl: _features[index]['imageUrl'],
                            icon: _features[index]['icon'],
                            isActive: index == _currentFeature,
                            onTap: () => _onFeatureTap(index),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Page indicators
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _features.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          width: index == _currentFeature ? 6.w : 2.w,
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: index == _currentFeature
                                ? colorScheme.primary
                                : colorScheme.outline.withAlpha(77),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Navigation buttons
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Row(
                      children: [
                        // Previous button
                        if (_currentFeature > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousFeature,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                side: BorderSide(
                                  color: colorScheme.outline,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Previous',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),

                        SizedBox(width: 4.w),

                        // Next/Complete button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextFeature,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentFeature == _features.length - 1
                                      ? 'Start Using Hakiki'
                                      : 'Next Feature',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  _currentFeature == _features.length - 1
                                      ? Icons.check_circle
                                      : Icons.arrow_forward,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
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
}
