import 'package:flutter/material.dart';
import '../../main_navigation/views/main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Bypass authentication - go directly to main dashboard
    return const MainNavigation();
  }
}
