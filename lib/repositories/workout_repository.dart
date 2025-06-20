import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';

class WorkoutRepository {
  /// Loads the workout blueprint from the local JSON asset file.
  Future<WorkoutBlueprint> getWorkoutBlueprint() async {
    // 1. Load the raw JSON string from the asset bundle
    final String jsonString = await rootBundle.loadString('assets/workouts.json');

    // 2. Decode the JSON string into a Map
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    // 3. Convert the Map into a WorkoutBlueprint object using our fromJson factory
    return WorkoutBlueprint.fromJson(jsonMap);
  }
}