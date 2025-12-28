import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dependency_injection.dart';
import '../../presentation/features/auth/viewmodels/auth_viewmodel.dart';
import '../../presentation/features/home/viewmodels/home_viewmodel.dart';
import '../../presentation/features/admin/viewmodels/admin_viewmodel.dart';
import '../../presentation/features/product/viewmodels/product_viewmodel.dart';
import '../../presentation/features/vendor/viewmodels/vendor_viewmodel.dart';
import '../../presentation/features/profile/viewmodels/profile_viewmodel.dart';
import '../../presentation/features/report/viewmodels/report_viewmodel.dart';
import '../../presentation/features/reports/viewmodels/fraud_viewmodel.dart';
import '../../presentation/features/verify/viewmodels/verify_viewmodel.dart';
import '../../presentation/features/product_verification_results/viewmodels/product_verification_viewmodel.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
        ),
        
        // Home Dashboard
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => getIt<HomeViewModel>(),
        ),
        
        // Admin Management
        ChangeNotifierProvider<AdminViewModel>(
          create: (_) => getIt<AdminViewModel>(),
        ),
        
        // Product Management
        ChangeNotifierProvider<ProductViewModel>(
          create: (_) => getIt<ProductViewModel>(),
        ),
        
        // Vendor Management
        ChangeNotifierProvider<VendorViewModel>(
          create: (_) => getIt<VendorViewModel>(),
        ),
        
        // User Profile
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => getIt<ProfileViewModel>(),
        ),
        
        // Report Management
        ChangeNotifierProvider<ReportViewModel>(
          create: (_) => getIt<ReportViewModel>(),
        ),
        
        // Fraud Reports
        ChangeNotifierProvider<FraudViewModel>(
          create: (_) => getIt<FraudViewModel>(),
        ),
        
        // Product Verification
        ChangeNotifierProvider<VerifyViewModel>(
          create: (_) => getIt<VerifyViewModel>(),
        ),
        
        // Product Verification Results
        ChangeNotifierProvider<ProductVerificationViewModel>(
          create: (_) => getIt<ProductVerificationViewModel>(),
        ),
      ],
      child: child,
    );
  }
}
