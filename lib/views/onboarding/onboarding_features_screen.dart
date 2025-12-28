/// Onboarding Features Screen
/// 
/// Shows key features of the Hakiki app.
/// Allows users to learn about the app's capabilities.
library;

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

class OnboardingFeaturesScreen extends StatelessWidget {
  const OnboardingFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Features title
              Text(
                'Key Features',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Feature 1
              _buildFeatureItem(
                context,
                icon: Icons.qr_code_scanner,
                title: AppStrings.feature1Title,
                description: AppStrings.feature1Description,
              ),
              const SizedBox(height: 24),
              // Feature 2
              _buildFeatureItem(
                context,
                icon: Icons.report_problem,
                title: AppStrings.feature2Title,
                description: AppStrings.feature2Description,
              ),
              const SizedBox(height: 24),
              // Feature 3
              _buildFeatureItem(
                context,
                icon: Icons.verified,
                title: AppStrings.feature3Title,
                description: AppStrings.feature3Description,
              ),
              const Spacer(),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

