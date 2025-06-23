import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/services/workout_state.dart';

class FakeWorkoutState extends ChangeNotifier implements WorkoutState {
  @override
  WorkoutBlueprint? _blueprint;

  @override
  int _currentDrillIndex = 0;

  @override
  bool _isPaused = false;

  @override
  final List<DrillResult> _sessionResults = [];

  int nextDrillCallCount = 0;
  int togglePauseCallCount = 0;

  @override
  bool get isWorkoutStarted => _blueprint != null;

  @override
  bool get isPaused => _isPaused;

  @override
  Drill? get currentDrill {
    if (_blueprint == null || _currentDrillIndex >= _blueprint!.drills.length) {
      return null;
    }
    return _blueprint!.drills[_currentDrillIndex];
  }

  @override
  int get totalDrills => _blueprint?.drills.length ?? 0;

  @override
  List<DrillResult> get results => _sessionResults;

  @override
  int get currentDrillIndex => _currentDrillIndex;

  @override
  double get workoutProgress {
    if (!isWorkoutStarted || totalDrills == 0) {
      return 0.0;
    }
    return (_currentDrillIndex + 1) / totalDrills;
  }

  @override
  String? get nextDrillName {
    if (_blueprint == null || _currentDrillIndex >= totalDrills - 1) {
      return null;
    }
    return _blueprint!.drills[_currentDrillIndex + 1].name;
  }

  @override
  void startWorkout(WorkoutBlueprint blueprint) {
    _blueprint = blueprint;
    _currentDrillIndex = 0;
    _isPaused = false;
    _sessionResults.clear();
    notifyListeners();
  }

  @override
  void nextDrill() {
    nextDrillCallCount++;
    if (_currentDrillIndex < totalDrills - 1) {
      _currentDrillIndex++;
    } else {
      _blueprint = null; // End of workout
    }
    notifyListeners();
  }

  @override
  void togglePause() {
    togglePauseCallCount++;
    _isPaused = !_isPaused;
    notifyListeners();
  }

  @override
  void logDrillResult(DrillResult result) {
    _sessionResults.add(result);
    notifyListeners();
  }

  @override
  void endWorkout() {
    _blueprint = null;
    _currentDrillIndex = 0;
    _sessionResults.clear();
    notifyListeners();
  }
}
