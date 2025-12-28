import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_test_service.dart';
import '../utils/logger.dart';
import '../../presentation/features/auth/viewmodels/auth_viewmodel.dart';
import '../../presentation/features/home/viewmodels/home_viewmodel.dart';
import '../../presentation/features/verify/viewmodels/verify_viewmodel.dart';
import '../../presentation/features/report/viewmodels/report_viewmodel.dart';
import '../../presentation/features/profile/viewmodels/profile_viewmodel.dart';
import '../../presentation/features/admin/viewmodels/admin_viewmodel.dart';
import '../../presentation/features/vendor/viewmodels/vendor_viewmodel.dart';
import '../../presentation/features/product/viewmodels/product_viewmodel.dart';
import '../../presentation/features/reports/viewmodels/fraud_viewmodel.dart';
import '../../presentation/features/product_verification_results/viewmodels/product_verification_viewmodel.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../data/repositories/fraud_repository.dart';
import '../../data/repositories/product_verification_repository.dart' show ProductVerificationRepository, ProductVerificationRepositoryImpl;

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // External Dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    
    // Firebase services - register with error handling
    try {
      getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
      getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
      getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
      getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
      getIt.registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
    } catch (e) {
      Logger.warning('Firebase services registration failed', tag: 'DependencyInjection', error: e);
      // Continue without Firebase services for development
    }

    // Core Services
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(
        firebaseAuth: getIt(),
        firestore: getIt(),
      ),
    );

    getIt.registerLazySingleton<FirestoreService>(
      () => FirestoreService(),
    );

    getIt.registerLazySingleton<StorageService>(
      () => StorageService(storage: getIt()),
    );

    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(messaging: getIt()),
    );

    getIt.registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(analytics: getIt()),
    );

    getIt.registerLazySingleton<CacheService>(
      () => CacheService(sharedPreferences: getIt()),
    );

    getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(),
    );

    getIt.registerLazySingleton<FirebaseTestService>(
      () => FirebaseTestService(),
    );

    // Repositories
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(getIt<FirestoreService>()),
    );

    getIt.registerLazySingleton<VendorRepository>(
      () => VendorRepository(getIt<FirestoreService>()),
    );

    getIt.registerLazySingleton<FraudRepository>(
      () => FraudRepository(getIt<FirestoreService>()),
    );

    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepository(getIt<FirestoreService>()),
    );

    getIt.registerLazySingleton<ProductVerificationRepository>(
      () => ProductVerificationRepositoryImpl(),
    );

    // ViewModels
    getIt.registerFactory<AuthViewModel>(
      () => AuthViewModel(getIt(), getIt()),
    );

    getIt.registerFactory<HomeViewModel>(
      () => HomeViewModel(
        authService: getIt(),
        firestoreService: getIt(),
      ),
    );

    getIt.registerFactory<VerifyViewModel>(
      () => VerifyViewModel(
        firestoreService: getIt(),
        authService: getIt(),
        analyticsService: getIt(),
      ),
    );

    getIt.registerFactory<ReportViewModel>(
      () => ReportViewModel(
        firestoreService: getIt(),
        storageService: getIt(),
        authService: getIt(),
        analyticsService: getIt(),
      ),
    );

    getIt.registerFactory<ProfileViewModel>(
      () => ProfileViewModel(
        authService: getIt(),
        firestoreService: getIt(),
        storageService: getIt(),
        analyticsService: getIt(),
        cacheService: getIt(),
      ),
    );

    getIt.registerFactory<AdminViewModel>(
      () => AdminViewModel(
        getIt<UserRepository>(),
        getIt<VendorRepository>(),
        getIt<FraudRepository>(),
      ),
    );

    getIt.registerFactory<VendorViewModel>(
      () => VendorViewModel(getIt<VendorRepository>()),
    );

    getIt.registerFactory<ProductViewModel>(
      () => ProductViewModel(getIt<ProductRepository>()),
    );

    getIt.registerFactory<FraudViewModel>(
      () => FraudViewModel(getIt<FraudRepository>()),
    );

    getIt.registerFactory<ProductVerificationViewModel>(
      () => ProductVerificationViewModel(
        repository: getIt<ProductVerificationRepository>(),
      ),
    );
  }

  static void reset() {
    getIt.reset();
  }
}
