/// Splash Screen
/// 
/// Initial screen shown when the app launches.
/// Handles app initialization and navigation to appropriate screen.
library;

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final authService = FirebaseAuthService();
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      // User is logged in, go to home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // User not logged in, go to onboarding
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingWelcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            const Icon(
              Icons.verified_user,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            // App tagline
            Text(
              AppStrings.appTagline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

