import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';

// A placeholder for our future DrillResult model
class DrillResult {
  final String drillId;
  //... more properties to come later
  DrillResult({required this.drillId});
}

class WorkoutState extends ChangeNotifier {
  WorkoutBlueprint? _blueprint;
  int _currentDrillIndex = 0;
  final List<DrillResult> _sessionResults = [];

  // Public getters to safely access the state
  bool get isWorkoutStarted => _blueprint != null;
  Drill? get currentDrill {
    if (_blueprint == null || _currentDrillIndex >= _blueprint!.drills.length) {
      return null;
    }
    return _blueprint!.drills[_currentDrillIndex];
  }

  int get totalDrills => _blueprint?.drills.length ?? 0;
  List<DrillResult> get results => _sessionResults;
  int get currentDrillIndex => _currentDrillIndex;

  double get workoutProgress {
    if (!isWorkoutStarted || totalDrills == 0) {
      return 0.0;
    }
    // Add 1 because index is 0-based but we want to show progress for the drill number
    return (_currentDrillIndex + 1) / totalDrills;
  }

  String? get nextDrillName {
    if (_blueprint == null || _currentDrillIndex >= totalDrills - 1) {
      return null; // No next drill
    }
    return _blueprint!.drills[_currentDrillIndex + 1].name;
  }

  // Method to start a new workout
  void startWorkout(WorkoutBlueprint blueprint) {
    _blueprint = blueprint;
    _currentDrillIndex = 0;
    _sessionResults.clear();

    // This is the key method from ChangeNotifier. It tells all listening
    // widgets that the state has changed and they need to rebuild.
    notifyListeners();
  }

  // Method to advance to the next drill
  void nextDrill() {
    if (_currentDrillIndex < totalDrills - 1) {
      _currentDrillIndex++;
      notifyListeners();
    } else {
      // Handle workout completion later
      endWorkout();
    }
  }

  // Method to log the result of a completed drill
  void logDrillResult(DrillResult result) {
    _sessionResults.add(result);
    notifyListeners();
  }

  // Method to end the workout and reset the state
  void endWorkout() {
    _blueprint = null;
    _currentDrillIndex = 0;
    _sessionResults.clear();
    notifyListeners();
  }
}
