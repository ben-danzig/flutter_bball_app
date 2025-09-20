import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:uuid/uuid.dart';

class CustomWorkoutRepository {
  static const String _localStorageKey = 'custom_workouts';
  static const String _draftKey = 'workout_draft';
  static const String _firestoreCollection = 'custom_workouts';
  
  final SharedPreferences sharedPreferences;
  final FirebaseFirestore firestore;
  final _uuid = const Uuid();

  CustomWorkoutRepository({
    required this.sharedPreferences,
    required this.firestore,
  });

  // Create
  Future<CustomWorkoutBlueprint> createWorkout(CustomWorkoutBlueprint workout) async {
    // Generate a new ID if not provided
    final newWorkout = workout.copyWith(
      id: workout.id.isEmpty ? _uuid.v4() : workout.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to local storage
    final workouts = await _getLocalWorkouts();
    workouts.add(newWorkout);
    await _saveLocalWorkouts(workouts);

    // Try to save to Firestore (fail silently if offline)
    try {
      await firestore
          .collection(_firestoreCollection)
          .doc(newWorkout.id)
          .set(newWorkout.toJson());
    } catch (e) {
      print('Failed to save to Firestore: $e');
      // Continue - local storage is the primary store
    }

    return newWorkout;
  }

  // Read - Get all workouts
  Future<List<CustomWorkoutBlueprint>> getAllWorkouts() async {
    return await _getLocalWorkouts();
  }

  // Read - Get single workout by ID
  Future<CustomWorkoutBlueprint?> getWorkoutById(String id) async {
    final workouts = await _getLocalWorkouts();
    try {
      return workouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  // Read - Get workouts by author
  Future<List<CustomWorkoutBlueprint>> getWorkoutsByAuthor(String authorId) async {
    final workouts = await _getLocalWorkouts();
    return workouts.where((w) => w.authorId == authorId).toList();
  }

  // Read - Get public workouts
  Future<List<CustomWorkoutBlueprint>> getPublicWorkouts() async {
    final workouts = await _getLocalWorkouts();
    return workouts.where((w) => w.isPublic).toList();
  }

  // Read - Search workouts by name
  Future<List<CustomWorkoutBlueprint>> searchWorkouts(String query) async {
    final workouts = await _getLocalWorkouts();
    final lowerQuery = query.toLowerCase();
    return workouts
        .where((w) => w.name.toLowerCase().contains(lowerQuery) ||
                      w.objective.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Read - Get workouts by category
  Future<List<CustomWorkoutBlueprint>> getWorkoutsByCategory(String category) async {
    final workouts = await _getLocalWorkouts();
    return workouts.where((w) => w.category == category).toList();
  }

  // Read - Get workouts by difficulty
  Future<List<CustomWorkoutBlueprint>> getWorkoutsByDifficulty(String difficulty) async {
    final workouts = await _getLocalWorkouts();
    return workouts.where((w) => w.difficulty == difficulty).toList();
  }

  // Read - Get workouts by tags
  Future<List<CustomWorkoutBlueprint>> getWorkoutsByTags(List<String> tags) async {
    final workouts = await _getLocalWorkouts();
    return workouts.where((w) => 
      tags.any((tag) => w.tags.contains(tag))
    ).toList();
  }

  // Update
  Future<CustomWorkoutBlueprint> updateWorkout(CustomWorkoutBlueprint workout) async {
    final workouts = await _getLocalWorkouts();
    final index = workouts.indexWhere((w) => w.id == workout.id);
    
    if (index == -1) {
      throw Exception('Workout not found');
    }

    // Update with new timestamp and increment version
    final updatedWorkout = workout.copyWith(
      updatedAt: DateTime.now(),
      version: workout.version + 1,
    );

    workouts[index] = updatedWorkout;
    await _saveLocalWorkouts(workouts);

    // Try to update in Firestore (fail silently if offline)
    try {
      await firestore
          .collection(_firestoreCollection)
          .doc(updatedWorkout.id)
          .update(updatedWorkout.toJson());
    } catch (e) {
      print('Failed to update in Firestore: $e');
      // Continue - local storage is the primary store
    }

    return updatedWorkout;
  }

  // Delete
  Future<void> deleteWorkout(String id) async {
    final workouts = await _getLocalWorkouts();
    workouts.removeWhere((w) => w.id == id);
    await _saveLocalWorkouts(workouts);

    // Try to delete from Firestore (fail silently if offline)
    try {
      await firestore
          .collection(_firestoreCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Failed to delete from Firestore: $e');
      // Continue - local storage is the primary store
    }
  }

  // Sync - Push local workouts to Firestore
  Future<void> syncToFirestore(String authorId) async {
    final localWorkouts = await getWorkoutsByAuthor(authorId);
    
    // Get remote workouts for this author
    final remoteSnapshot = await firestore
        .collection(_firestoreCollection)
        .where('authorId', isEqualTo: authorId)
        .get();
    
    final remoteWorkouts = remoteSnapshot.docs
        .map((doc) => CustomWorkoutBlueprint.fromJson(doc.data()))
        .toList();
    
    // Create a map of remote workouts by ID for quick lookup
    final remoteMap = {for (var w in remoteWorkouts) w.id: w};
    
    // Upload local workouts that are newer or don't exist remotely
    for (final localWorkout in localWorkouts) {
      final remoteWorkout = remoteMap[localWorkout.id];
      
      if (remoteWorkout == null || 
          localWorkout.updatedAt.isAfter(remoteWorkout.updatedAt)) {
        try {
          await firestore
              .collection(_firestoreCollection)
              .doc(localWorkout.id)
              .set(localWorkout.toJson());
        } catch (e) {
          print('Failed to sync workout ${localWorkout.id}: $e');
        }
      }
    }
  }

  // Sync - Pull workouts from Firestore to local
  Future<void> syncFromFirestore(String authorId) async {
    try {
      // Get remote workouts for this author
      final remoteSnapshot = await firestore
          .collection(_firestoreCollection)
          .where('authorId', isEqualTo: authorId)
          .get();
      
      final remoteWorkouts = remoteSnapshot.docs
          .map((doc) => CustomWorkoutBlueprint.fromJson(doc.data()))
          .toList();
      
      // Get local workouts
      final localWorkouts = await _getLocalWorkouts();
      
      // Create a map of local workouts by ID for quick lookup
      final localMap = {for (var w in localWorkouts) w.id: w};
      
      // Process remote workouts
      for (final remoteWorkout in remoteWorkouts) {
        final localWorkout = localMap[remoteWorkout.id];
        
        if (localWorkout == null) {
          // Remote workout doesn't exist locally, add it
          localWorkouts.add(remoteWorkout);
        } else if (remoteWorkout.version > localWorkout.version ||
                   remoteWorkout.updatedAt.isAfter(localWorkout.updatedAt)) {
          // Remote workout is newer, replace local version
          final index = localWorkouts.indexWhere((w) => w.id == remoteWorkout.id);
          if (index != -1) {
            localWorkouts[index] = remoteWorkout;
          }
        }
        // If local is newer, keep it (will be synced up later)
      }
      
      // Save updated local workouts
      await _saveLocalWorkouts(localWorkouts);
    } catch (e) {
      print('Failed to sync from Firestore: $e');
      // Continue with local data
    }
  }

  // Draft Management
  Future<void> saveDraft(CustomWorkoutBlueprint draft) async {
    final json = jsonEncode(draft.toJson());
    await sharedPreferences.setString(_draftKey, json);
  }

  Future<CustomWorkoutBlueprint?> loadDraft() async {
    final json = sharedPreferences.getString(_draftKey);
    if (json == null) return null;
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return CustomWorkoutBlueprint.fromJson(data);
    } catch (e) {
      print('Failed to load draft: $e');
      return null;
    }
  }

  Future<void> clearDraft() async {
    await sharedPreferences.remove(_draftKey);
  }

  // Private helper methods
  Future<List<CustomWorkoutBlueprint>> _getLocalWorkouts() async {
    final json = sharedPreferences.getString(_localStorageKey);
    if (json == null) return [];
    
    try {
      final List<dynamic> data = jsonDecode(json);
      return data
          .map((item) => CustomWorkoutBlueprint.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to load local workouts: $e');
      return [];
    }
  }

  Future<void> _saveLocalWorkouts(List<CustomWorkoutBlueprint> workouts) async {
    final json = jsonEncode(workouts.map((w) => w.toJson()).toList());
    await sharedPreferences.setString(_localStorageKey, json);
  }
}