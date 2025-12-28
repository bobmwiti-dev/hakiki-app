import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/product_verification_repository.dart';
import '../../presentation/features/product_verification_results/viewmodels/product_verification_viewmodel.dart';

class ProductVerificationProvider extends StatelessWidget {
  final Widget child;

  const ProductVerificationProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductVerificationRepository>(
          create: (_) => ProductVerificationRepositoryImpl(),
        ),
        ChangeNotifierProxyProvider<ProductVerificationRepository, ProductVerificationViewModel>(
          create: (context) => ProductVerificationViewModel(
            repository: context.read<ProductVerificationRepository>(),
          ),
          update: (context, repository, previous) => previous ?? ProductVerificationViewModel(
            repository: repository,
          ),
        ),
      ],
      child: child,
    );
  }
}
