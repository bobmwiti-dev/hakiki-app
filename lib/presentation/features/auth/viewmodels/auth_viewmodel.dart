import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  AuthViewModel(this._authService, this._userRepository);

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for compatibility
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isVendor => _currentUser?.role == 'vendor';
  bool get isUser => _currentUser?.role == 'user';

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setCurrentUser(UserModel? user) {
    _currentUser = user;
    _isAuthenticated = user != null;
    notifyListeners();
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      Logger.info('Initializing auth state', tag: 'AuthViewModel');
      _setLoading(true);
      
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final user = await _userRepository.getUserById(firebaseUser.uid);
        _setCurrentUser(user);
        Logger.info('User authenticated: ${user?.email}', tag: 'AuthViewModel');
      } else {
        _setCurrentUser(null);
        Logger.info('No authenticated user found', tag: 'AuthViewModel');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize auth state', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      Logger.info('Signing in with email: $email', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        final user = await _userRepository.getUserById(userCredential.user!.uid);
        if (user != null) {
          _setCurrentUser(user);
          Logger.info('Sign in successful: ${user.email}', tag: 'AuthViewModel');
          return true;
        } else {
          throw Exception('User data not found');
        }
      }
      return false;
    } catch (e, stackTrace) {
      Logger.error('Sign in failed for email: $email', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      Logger.info('Signing up with email: $email', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(displayName);
        
        // Create user document in Firestore
        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          role: 'user',
          trustScore: 50,
          isVerified: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final createdUser = await _userRepository.createUser(newUser);
        _setCurrentUser(createdUser);
        Logger.info('Sign up successful: ${createdUser.email}', tag: 'AuthViewModel');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      Logger.error('Sign up failed for email: $email', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      Logger.info('Signing in with Google', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.signInWithGoogle();
      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        
        // Check if user exists in Firestore
        UserModel? user = await _userRepository.getUserById(firebaseUser.uid);
        
        if (user == null) {
          // Create new user document
          final newUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            role: 'user',
            trustScore: 50,
            isVerified: firebaseUser.emailVerified,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          user = await _userRepository.createUser(newUser);
        }

        _setCurrentUser(user);
        Logger.info('Google sign in successful: ${user.email}', tag: 'AuthViewModel');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      Logger.error('Google sign in failed', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear verification ID
  void clearVerificationId() {
    // Implementation for clearing verification ID
    notifyListeners();
  }

  // Sign in with phone number
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    try {
      Logger.info('Initiating phone sign in: $phoneNumber', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      await _authService.signInWithPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _authService.verifyPhoneNumberWithCode(
            verificationId: credential.verificationId!,
            smsCode: credential.smsCode!,
          );
          await _handlePhoneSignInResult(userCredential, phoneNumber);
        },
        verificationFailed: (FirebaseAuthException e) {
          Logger.error('Phone verification failed', 
              tag: 'AuthViewModel', error: e);
          _setError(_getErrorMessage(e));
          _setLoading(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          Logger.info('OTP sent to: $phoneNumber', tag: 'AuthViewModel');
          _setLoading(false);
          // Store verification ID for later use
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Logger.info('Auto retrieval timeout for: $phoneNumber', tag: 'AuthViewModel');
          _setLoading(false);
        },
      );
    } catch (e, stackTrace) {
      Logger.error('Phone sign in failed for: $phoneNumber', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  // Verify phone number with code
  Future<bool> verifyPhoneNumberWithCode(String verificationId, String otp) async {
    try {
      Logger.info('Verifying OTP', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.verifyPhoneNumberWithCode(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _handlePhoneSignInResult(userCredential, '');
    } catch (e, stackTrace) {
      Logger.error('OTP verification failed', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _handlePhoneSignInResult(UserCredential userCredential, String phoneNumber) async {
    if (userCredential.user != null) {
      final firebaseUser = userCredential.user!;
      
      // Check if user exists in Firestore
      UserModel? user = await _userRepository.getUserById(firebaseUser.uid);
      
      if (user == null) {
        // Create new user document
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber ?? phoneNumber,
          role: 'user',
          trustScore: 50,
          isVerified: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        user = await _userRepository.createUser(newUser);
      }

      _setCurrentUser(user);
      Logger.info('Phone sign in successful: ${user.phoneNumber}', tag: 'AuthViewModel');
      return true;
    }
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      Logger.info('Signing out user: ${_currentUser?.email}', tag: 'AuthViewModel');
      _setLoading(true);
      
      await _authService.signOut();
      _setCurrentUser(null);
      Logger.info('Sign out successful', tag: 'AuthViewModel');
    } catch (e, stackTrace) {
      Logger.error('Sign out failed', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      Logger.info('Resetting password for: $email', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      Logger.info('Password reset email sent to: $email', tag: 'AuthViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Password reset failed for: $email', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(String displayName, String? photoUrl) async {
    try {
      Logger.info('Updating profile for user: ${_currentUser?.id}', tag: 'AuthViewModel');
      _setLoading(true);
      _setError(null);

      if (_currentUser == null) {
        throw Exception('No authenticated user');
      }

      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );

      final user = await _userRepository.updateUser(updatedUser);
      _setCurrentUser(user);
      Logger.info('Profile updated successfully', tag: 'AuthViewModel');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Profile update failed', 
          tag: 'AuthViewModel', error: e, stackTrace: stackTrace);
      _setError('Failed to update profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'network-request-failed':
          return 'Network error. Please check your connection';
        default:
          return error.message ?? 'Authentication failed';
      }
    }
    return error.toString();
  }

  void clearError() {
    _setError(null);
  }
}
