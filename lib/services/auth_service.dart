import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bball_app/repositories/user_repository.dart';
import 'package:flutter_bball_app/models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository = UserRepository();
  Timer? _notifyDebouncer;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    // Initialize GoogleSignIn with proper web configuration
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: const String.fromEnvironment('WEB_CLIENT_ID'),
        scopes: ['email', 'profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
    
    _auth.authStateChanges().listen((User? user) async {
      print('[AuthService] Auth state changed: ${user?.uid}');
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        print('[AuthService] User is null, clearing profile and notifying listeners');
        _userProfile = null;
      }
      
      // Debounce notifications to prevent rapid-fire calls during signup
      _notifyDebouncer?.cancel();
      _notifyDebouncer = Timer(const Duration(milliseconds: 50), () {
        print('[AuthService] About to notify listeners - isAuthenticated: $isAuthenticated, currentUser: ${currentUser?.uid}');
        notifyListeners();
      });
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      print('[AuthService] Loading user profile for $userId');
      _userProfile = await _userRepository.getUserProfile(userId);
      if (_userProfile == null && _auth.currentUser != null) {
        print('[AuthService] No user profile found, creating new profile');
        // Create user profile with proper error handling
        try {
          _userProfile = await _userRepository.createUserProfileFromAuth(_auth.currentUser!);
        } catch (e) {
          print('[AuthService] Failed to create user profile, but continuing: $e');
          // Even if profile creation fails, we can still continue with authentication
          // The user can still access the app without a complete profile
        }
      }
    } catch (e) {
      print('[AuthService] Failed to load user profile: $e');
      // Don't throw error here as it would prevent auth flow
    }
  }

  // Email & Password Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('[AuthService] Signing up with email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Don't create user profile here - let the auth state change listener handle it
      // This avoids race conditions between multiple profile creation attempts
      print('[AuthService] Signup successful, auth state change will handle profile creation');
      
      return credential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Signup error: $e');
      throw _handleAuthException(e);
    }
  }

  // Email & Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('[AuthService] Signing in with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (credential.user != null) {
        print('[AuthService] Sign in successful, updating last login');
        try {
          await _userRepository.updateLastLogin(credential.user!.uid);
        } catch (e) {
          print('[AuthService] Failed to update last login, but continuing: $e');
        }
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Sign in error: $e');
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('[AuthService] Starting Google Sign-In');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('[AuthService] Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('[AuthService] Google Auth obtained');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print('[AuthService] Firebase sign-in successful: ${userCredential.user?.uid}');

      // Update last login time for Google sign-in
      if (userCredential.user != null) {
        try {
          await _userRepository.updateLastLogin(userCredential.user!.uid);
          print('[AuthService] User profile last login updated');
        } catch (e) {
          print('[AuthService] Failed to update last login, but continuing: $e');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Google Sign-In error: $e');
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print('[AuthService] Signing out');
      
      // For web, we'll focus on Firebase signout and handle Google Sign-In differently
      if (kIsWeb) {
        // On web, just sign out from Firebase - this will handle most cases
        await _auth.signOut();
        print('[AuthService] Firebase sign out complete');
        
        // Try Google Sign-In logout but don't fail if it errors
        try {
          await _googleSignIn.signOut();
          print('[AuthService] Google Sign-In sign out successful');
        } catch (e) {
          print('[AuthService] Google Sign-In sign out failed (this is expected on web): $e');
          // This is expected and OK - Firebase signout is what matters
        }
      } else {
        // On mobile platforms, sign out from both
        try {
          await _googleSignIn.signOut();
          print('[AuthService] Google Sign-In sign out successful');
        } catch (e) {
          print('[AuthService] Google Sign-In sign out error (continuing with Firebase): $e');
        }
        
        await _auth.signOut();
        print('[AuthService] Firebase sign out complete');
      }
      
      // Explicitly clear user profile and notify listeners
      _userProfile = null;
      print('[AuthService] User profile cleared, notifying listeners');
      notifyListeners();
      
    } catch (e) {
      print('[AuthService] Sign out error: $e');
      // For web Google Sign-In errors, still try to sign out from Firebase
      try {
        await _auth.signOut();
        // Even on error, clear the profile and notify
        _userProfile = null;
        notifyListeners();
        print('[AuthService] Firebase fallback sign out complete');
      } catch (fallbackError) {
        print('[AuthService] Firebase fallback sign out also failed: $fallbackError');
        throw Exception('Failed to sign out: $fallbackError');
      }
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('[AuthService] Sending password reset email to $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('[AuthService] Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Password reset error: $e');
      throw _handleAuthException(e);
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      print('[AuthService] Updating password');
      await _auth.currentUser?.updatePassword(newPassword);
      print('[AuthService] Password updated');
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Update password error: $e');
      throw _handleAuthException(e);
    }
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    try {
      print('[AuthService] Updating email to $newEmail');
      await _auth.currentUser?.updateEmail(newEmail);
      print('[AuthService] Email updated');
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Update email error: $e');
      throw _handleAuthException(e);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      print('[AuthService] Deleting account');
      await _auth.currentUser?.delete();
      print('[AuthService] Account deleted');
    } on FirebaseAuthException catch (e) {
      print('[AuthService] Delete account error: $e');
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    print('[AuthService] Handling auth exception: ${e.code}');
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  @override
  void dispose() {
    _notifyDebouncer?.cancel();
    super.dispose();
  }
} 