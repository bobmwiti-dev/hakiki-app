/// Firebase Auth Service
/// 
/// Wrapper service for Firebase Authentication.
/// Provides a clean interface for authentication operations.
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Signing in with email: $email', tag: 'FirebaseAuth');
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Logger.error('Sign in failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Signing up with email: $email', tag: 'FirebaseAuth');
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Logger.error('Sign up failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      Logger.info('Signing out user', tag: 'FirebaseAuth');
      await _auth.signOut();
    } catch (e) {
      Logger.error('Sign out failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.info('Sending password reset email to: $email', tag: 'FirebaseAuth');
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      Logger.error('Password reset failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      Logger.info('Profile updated successfully', tag: 'FirebaseAuth');
    } catch (e) {
      Logger.error('Profile update failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }

  // Verify phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      Logger.info('Verifying phone number: $phoneNumber', tag: 'FirebaseAuth');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      Logger.error('Phone verification failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }

  // Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      Logger.error('Phone sign in failed', tag: 'FirebaseAuth', error: e);
      rethrow;
    }
  }
}

