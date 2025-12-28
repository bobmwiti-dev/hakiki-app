/// Auth ViewModel
/// 
/// Manages authentication state and business logic.
/// Handles login, signup, logout, and user session management.
library;

import 'package:flutter/foundation.dart';
import '../core/services/firebase_auth_service.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';
import '../core/utils/logger.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserRepository _userRepository;

  AuthViewModel({
    required FirebaseAuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository {
    _init();
  }

  // State
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Initialize
  Future<void> _init() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load user data
  Future<void> _loadUserData(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _userRepository.getUserById(userId);
    } catch (e) {
      Logger.error('Failed to load user data', tag: 'AuthViewModel', error: e);
      _errorMessage = 'Failed to load user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      Logger.error('Sign in failed', tag: 'AuthViewModel', error: e);
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await _authService.updateProfile(displayName: displayName);

      // Create user document
      if (credential.user != null) {
        await _userRepository.createUser(
          UserModel(
            id: credential.user!.uid,
            email: email,
            displayName: displayName,
            role: 'user',
            trustScore: 0,
            isVerified: false,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      return true;
    } catch (e) {
      Logger.error('Sign up failed', tag: 'AuthViewModel', error: e);
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      Logger.error('Sign out failed', tag: 'AuthViewModel', error: e);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      Logger.error('Password reset failed', tag: 'AuthViewModel', error: e);
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

