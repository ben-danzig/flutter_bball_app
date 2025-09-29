import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:flutter_bball_app/repositories/custom_workout_repository.dart';

class WorkoutRepository {
  final CustomWorkoutRepository? customWorkoutRepository;

  WorkoutRepository({this.customWorkoutRepository});

  /// Loads all workout blueprints from both local JSON assets and custom workouts.
  /// 
  /// [includePreBuilt] - Include pre-built workouts from assets (default: true)
  /// [includeCustom] - Include custom user-created workouts (default: true)
  /// [sortBy] - Sort results by 'name' or 'duration' (default: null, no sorting)
  Future<List<WorkoutBlueprint>> getAllWorkoutBlueprints({
    bool includePreBuilt = true,
    bool includeCustom = true,
    String? sortBy,
  }) async {
    final List<WorkoutBlueprint> allBlueprints = [];

    // 1. Load pre-built workouts if requested
    if (includePreBuilt) {
      // Load the main production workout
      try {
        final String prodJsonString =
            await rootBundle.loadString('assets/workouts.json');
        final List<dynamic> prodJsonList = jsonDecode(prodJsonString);
        final List<WorkoutBlueprint> prodBlueprints = prodJsonList
            .map((json) => WorkoutBlueprint.fromJson(json))
            .toList();
        allBlueprints.addAll(prodBlueprints);
      } catch (e) {
        // Handle error if the main workout file is missing or corrupt
        print('Error loading production workout: $e');
      }

      // Load the test workouts
      try {
        final String testJsonString =
            await rootBundle.loadString('assets/test_workouts.json');
        final List<dynamic> testJsonList = jsonDecode(testJsonString);
        final List<WorkoutBlueprint> testBlueprints = testJsonList
            .map((json) => WorkoutBlueprint.fromJson(json))
            .toList();
        allBlueprints.addAll(testBlueprints);
      } catch (e) {
        // It's okay if test workouts are not present, especially in production.
        print('Note: Test workouts not found or could not be loaded. $e');
      }
    }

    // 2. Load custom workouts if requested and repository is available
    if (includeCustom && customWorkoutRepository != null) {
      try {
        final customWorkouts = await customWorkoutRepository!.getAllWorkouts();
        allBlueprints.addAll(customWorkouts);
      } catch (e) {
        print('Error loading custom workouts: $e');
        // Continue with pre-built workouts
      }
    }

    // 3. Sort if requested
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          allBlueprints.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'duration':
          allBlueprints.sort((a, b) => a.estimatedDuration.compareTo(b.estimatedDuration));
          break;
      }
    }

    return allBlueprints;
  }

  /// Gets a workout by ID from either pre-built or custom workouts.
  Future<WorkoutBlueprint?> getWorkoutById(String id) async {
    // First check custom workouts
    if (customWorkoutRepository != null) {
      try {
        final customWorkout = await customWorkoutRepository!.getWorkoutById(id);
        if (customWorkout != null) {
          return customWorkout;
        }
      } catch (e) {
        print('Error getting custom workout by ID: $e');
      }
    }

    // Then check pre-built workouts
    final allPreBuilt = await getAllWorkoutBlueprints(includeCustom: false);
    try {
      return allPreBuilt.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Searches workouts by name or objective.
  Future<List<WorkoutBlueprint>> searchWorkouts(String query) async {
    final List<WorkoutBlueprint> results = [];
    final lowerQuery = query.toLowerCase();

    // Search pre-built workouts
    final preBuilt = await getAllWorkoutBlueprints(includeCustom: false);
    results.addAll(preBuilt.where((w) =>
        w.name.toLowerCase().contains(lowerQuery) ||
        w.objective.toLowerCase().contains(lowerQuery)));

    // Search custom workouts
    if (customWorkoutRepository != null) {
      try {
        final customResults = await customWorkoutRepository!.searchWorkouts(query);
        results.addAll(customResults);
      } catch (e) {
        print('Error searching custom workouts: $e');
      }
    }

    return results;
  }

  /// Gets workouts by category (custom workouts only).
  Future<List<WorkoutBlueprint>> getWorkoutsByCategory(String category) async {
    if (customWorkoutRepository == null) {
      return [];
    }

    try {
      return await customWorkoutRepository!.getWorkoutsByCategory(category);
    } catch (e) {
      print('Error getting workouts by category: $e');
      return [];
    }
  }

  /// Gets workouts by difficulty (custom workouts only).
  Future<List<WorkoutBlueprint>> getWorkoutsByDifficulty(String difficulty) async {
    if (customWorkoutRepository == null) {
      return [];
    }

    try {
      return await customWorkoutRepository!.getWorkoutsByDifficulty(difficulty);
    } catch (e) {
      print('Error getting workouts by difficulty: $e');
      return [];
    }
  }

  /// Gets workouts by author (custom workouts only).
  Future<List<WorkoutBlueprint>> getWorkoutsByAuthor(String authorId) async {
    if (customWorkoutRepository == null) {
      return [];
    }

    try {
      return await customWorkoutRepository!.getWorkoutsByAuthor(authorId);
    } catch (e) {
      print('Error getting workouts by author: $e');
      return [];
    }
  }

  /// Gets public workouts (custom workouts only).
  Future<List<WorkoutBlueprint>> getPublicWorkouts() async {
    if (customWorkoutRepository == null) {
      return [];
    }

    try {
      return await customWorkoutRepository!.getPublicWorkouts();
    } catch (e) {
      print('Error getting public workouts: $e');
      return [];
    }
  }
}
