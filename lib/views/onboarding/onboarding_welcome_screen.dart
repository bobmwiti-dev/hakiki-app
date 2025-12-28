/// Onboarding Welcome Screen
/// 
/// First screen in the onboarding flow.
/// Welcomes users to the Hakiki app.
library;

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome illustration
              const Icon(
                Icons.verified_user_outlined,
                size: 120,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              // Welcome title
              Text(
                AppStrings.welcomeTitle,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Welcome subtitle
              Text(
                AppStrings.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Get started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.onboardingFeatures);
                  },
                  child: const Text(AppStrings.getStarted),
                ),
              ),
              const SizedBox(height: 16),
              // Skip button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                child: const Text(AppStrings.skip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

