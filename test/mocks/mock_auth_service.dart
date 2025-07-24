import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bball_app/services/auth_service.dart';
import 'package:flutter_bball_app/models/user_profile.dart';

// Mock Firebase User
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
  
  @override
  String? get email => 'test@example.com';
  
  @override
  String? get displayName => 'Test User';
}

// Mock UserCredential
class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockUser();
}

// Mock AuthService
class MockAuthService extends ChangeNotifier implements AuthService {
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isAuthenticated = false;
  
  // Control flags for error simulation
  bool _shouldThrowSignUpError = false;
  bool _shouldThrowSignInError = false;
  String _errorCode = 'unknown';

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  UserProfile? get userProfile => _userProfile;

  // Helper methods to control mock state
  void setAuthenticatedUser({
    String uid = 'test-user-id', 
    String email = 'test@example.com',
    String displayName = 'Test User'
  }) {
    _currentUser = MockUser();
    _userProfile = UserProfile(
      id: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void setUnauthenticated() {
    _currentUser = null;
    _userProfile = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Error simulation helpers
  void simulateSignUpError(String errorCode) {
    _shouldThrowSignUpError = true;
    _errorCode = errorCode;
  }

  void simulateSignInError(String errorCode) {
    _shouldThrowSignInError = true;
    _errorCode = errorCode;
  }

  void clearErrors() {
    _shouldThrowSignUpError = false;
    _shouldThrowSignInError = false;
  }

  // AuthService method implementations
  @override
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    if (_shouldThrowSignUpError) {
      throw FirebaseAuthException(code: _errorCode, message: 'Test error');
    }
    setAuthenticatedUser(email: email);
    return MockUserCredential();
  }

  @override
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    if (_shouldThrowSignInError) {
      throw FirebaseAuthException(code: _errorCode, message: 'Test error');
    }
    setAuthenticatedUser(email: email);
    return MockUserCredential();
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    setAuthenticatedUser(email: 'google@example.com');
    return MockUserCredential();
  }

  @override
  Future<void> signOut() async {
    setUnauthenticated();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate password reset email sent
    return;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    // Simulate password update
    return;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    // Simulate email update
    return;
  }

  @override
  Future<void> deleteAccount() async {
    // Simulate account deletion
    setUnauthenticated();
  }
} 