import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bball_app/repositories/user_repository.dart';
import 'package:flutter_bball_app/models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? dotenv.env['WEB_CLIENT_ID'] : null,
  );
  final UserRepository _userRepository = UserRepository();

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      print('[AuthService] Auth state changed: ${user?.uid}');
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      print('[AuthService] Loading user profile for $userId');
      _userProfile = await _userRepository.getUserProfile(userId);
      if (_userProfile == null && _auth.currentUser != null) {
        print('[AuthService] No user profile found, creating new profile');
        _userProfile = await _userRepository.createUserProfileFromAuth(_auth.currentUser!);
      }
    } catch (e) {
      print('[AuthService] Failed to load user profile: $e');
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
      
      // Create user profile after successful signup
      if (credential.user != null) {
        print('[AuthService] Signup successful, creating user profile');
        await _userRepository.createUserProfileFromAuth(credential.user!);
      }
      
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
        await _userRepository.updateLastLogin(credential.user!.uid);
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

      if (userCredential.user != null) {
        await _userRepository.createUserProfileFromAuth(userCredential.user!);
        await _userRepository.updateLastLogin(userCredential.user!.uid);
        print('[AuthService] User profile created/updated');
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
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('[AuthService] Sign out complete');
    } catch (e) {
      print('[AuthService] Sign out error: $e');
      throw Exception('Failed to sign out: $e');
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
} 