import 'package:firebase_core/firebase_core.dart';
import 'core/app_export.dart';
import 'core/services/dependency_injection.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Logger.info('Firebase initialized successfully', tag: 'Main');
  } catch (e) {
    // Firebase initialization failed - this will prevent the app from working properly
    Logger.error('Firebase initialization failed', tag: 'Main', error: e);
    Logger.error('Please check your firebase_options.dart configuration', tag: 'Main');
    // Don't continue without Firebase as the app depends on it
    rethrow;
  }
  
  // Initialize dependency injection
  await DependencyInjection.init();

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(const Duration(seconds: 5), () {
        hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return const SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(const HakikiApp());
  });
}

