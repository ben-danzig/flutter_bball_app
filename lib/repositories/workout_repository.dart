import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';

class WorkoutRepository {
  /// Loads all workout blueprints from the local JSON asset files.
  Future<List<WorkoutBlueprint>> getAllWorkoutBlueprints() async {
    final List<WorkoutBlueprint> allBlueprints = [];

    // 1. Load the main production workout
    try {
      print('DEBUG: Loading production workouts from assets/workouts.json');
      final String prodJsonString =
          await rootBundle.loadString('assets/workouts.json');
      print('DEBUG: Successfully loaded workouts.json, length: ${prodJsonString.length}');
      final List<dynamic> prodJsonList = jsonDecode(prodJsonString);
      print('DEBUG: Parsed JSON, found ${prodJsonList.length} workouts');
      final List<WorkoutBlueprint> prodBlueprints = prodJsonList
          .map((json) => WorkoutBlueprint.fromJson(json))
          .toList();
      print('DEBUG: Created ${prodBlueprints.length} workout blueprints');
      for (var workout in prodBlueprints) {
        print('DEBUG: Found workout: "${workout.name}" (id: ${workout.id})');
      }
      allBlueprints.addAll(prodBlueprints);
    } catch (e) {
      // Handle error if the main workout file is missing or corrupt
      print('ERROR: Error loading production workout: $e');
    }

    // 2. Load the test workouts
    try {
      print('DEBUG: Loading test workouts from assets/test_workouts.json');
      final String testJsonString =
          await rootBundle.loadString('assets/test_workouts.json');
      print('DEBUG: Successfully loaded test_workouts.json, length: ${testJsonString.length}');
      final List<dynamic> testJsonList = jsonDecode(testJsonString);
      print('DEBUG: Parsed test JSON, found ${testJsonList.length} test workouts');
      final List<WorkoutBlueprint> testBlueprints = testJsonList
          .map((json) => WorkoutBlueprint.fromJson(json))
          .toList();
      print('DEBUG: Created ${testBlueprints.length} test workout blueprints');
      for (var workout in testBlueprints) {
        print('DEBUG: Found test workout: "${workout.name}" (id: ${workout.id})');
      }
      allBlueprints.addAll(testBlueprints);
    } catch (e) {
      // It's okay if test workouts are not present, especially in production.
      print('INFO: Test workouts not found or could not be loaded. $e');
    }

    print('DEBUG: Total workouts loaded: ${allBlueprints.length}');
    return allBlueprints;
  }
}
