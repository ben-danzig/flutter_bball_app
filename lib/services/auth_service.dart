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
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      
      // Debounce notifications to prevent rapid-fire calls during signup
      _notifyDebouncer?.cancel();
      _notifyDebouncer = Timer(const Duration(milliseconds: 50), () {
        notifyListeners();
      });
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _userProfile = await _userRepository.getUserProfile(userId);
      if (_userProfile == null && _auth.currentUser != null) {
        // Create user profile with proper error handling
        try {
          _userProfile = await _userRepository.createUserProfileFromAuth(_auth.currentUser!);
        } catch (e) {
          // Even if profile creation fails, we can still continue with authentication
          // The user can still access the app without a complete profile
        }
      }
    } catch (e) {
      // Don't throw error here as it would prevent auth flow
    }
  }

  // Email & Password Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Don't create user profile here - let the auth state change listener handle it
      // This avoids race conditions between multiple profile creation attempts
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email & Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (credential.user != null) {
        try {
          await _userRepository.updateLastLogin(credential.user!.uid);
        } catch (e) {
          // Failed to update last login, but continuing
        }
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Update last login time for Google sign-in
      if (userCredential.user != null) {
        try {
          await _userRepository.updateLastLogin(userCredential.user!.uid);
        } catch (e) {
          // Failed to update last login, but continuing
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      
      // For web, we'll focus on Firebase signout and handle Google Sign-In differently
      if (kIsWeb) {
        // On web, just sign out from Firebase - this will handle most cases
        await _auth.signOut();
        
        // Try Google Sign-In logout but don't fail if it errors
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          // This is expected and OK - Firebase signout is what matters
        }
      } else {
        // On mobile platforms, sign out from both
        try {
          await _googleSignIn.signOut();
        } catch (e) {
        }
        
        await _auth.signOut();
      }
      
      // Explicitly clear user profile and notify listeners
      _userProfile = null;
      notifyListeners();
      
    } catch (e) {
      // For web Google Sign-In errors, still try to sign out from Firebase
      try {
        await _auth.signOut();
        // Even on error, clear the profile and notify
        _userProfile = null;
        notifyListeners();
      } catch (fallbackError) {
        throw Exception('Failed to sign out: $fallbackError');
      }
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
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