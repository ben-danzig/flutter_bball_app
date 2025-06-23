import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';

class WorkoutRepository {
  /// Loads all workout blueprints from the local JSON asset files.
  Future<List<WorkoutBlueprint>> getAllWorkoutBlueprints() async {
    final List<WorkoutBlueprint> allBlueprints = [];

    // 1. Load the main production workout
    try {
      final String prodJsonString =
          await rootBundle.loadString('assets/workouts.json');
      final Map<String, dynamic> prodJsonMap = jsonDecode(prodJsonString);
      allBlueprints.add(WorkoutBlueprint.fromJson(prodJsonMap));
    } catch (e) {
      // Handle error if the main workout file is missing or corrupt
      print('Error loading production workout: $e');
    }

    // 2. Load the test workouts
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

    return allBlueprints;
  }
}
