import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/app_routes.dart';

class HakikiApp extends StatelessWidget {
  const HakikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: 'Hakiki',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
        // home: const SplashScreen(), // Using initialRoute instead
      ),
    );
  }
}
