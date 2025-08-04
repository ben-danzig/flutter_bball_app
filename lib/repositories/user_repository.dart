import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bball_app/models/user_profile.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Create or update user profile
  Future<void> createOrUpdateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to create/update user profile: $e');
    }
  }

  // Create user profile from Firebase Auth user
  Future<UserProfile> createUserProfileFromAuth(User user) async {
    final profile = UserProfile(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await createOrUpdateUserProfile(profile);
    return profile;
  }

  // Update last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
} 