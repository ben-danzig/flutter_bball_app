import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/drill_result.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/services/workout_state.dart';

class FakeWorkoutState extends ChangeNotifier implements WorkoutState {
  @override
  WorkoutBlueprint? _blueprint;

  @override
  int _currentDrillIndex = 0;

  @override
  int _currentDrillElapsedSeconds = 0;

  @override
  bool _isPaused = false;

  @override
  final List<DrillResult> _sessionResults = [];

  int nextDrillCallCount = 0;
  int togglePauseCallCount = 0;
  DrillResult? lastLoggedResult;

  @override
  bool get isWorkoutStarted => _blueprint != null;

  @override
  bool get isWorkoutComplete => _blueprint != null && _currentDrillIndex >= totalDrills;

  @override
  WorkoutBlueprint? get workoutBlueprint => _blueprint;

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
  int get currentDrillElapsedSeconds => _currentDrillElapsedSeconds;

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
    nextDrillCallCount = 0;
    togglePauseCallCount = 0;
    lastLoggedResult = null;
    notifyListeners();
  }

  @override
  void nextDrill() {
    nextDrillCallCount++;
    if (_currentDrillIndex < totalDrills) {
      _currentDrillIndex++;
      _currentDrillElapsedSeconds = 0;
    }
    notifyListeners();
  }

  @override
  void tick() {
    if (!_isPaused) {
      _currentDrillElapsedSeconds++;
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
  void _logDrillResult(DrillResult result) {
    _sessionResults.add(result);
    lastLoggedResult = result;
  }

  @override
  void logTimedDrill() {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      elapsedSeconds: currentDrill!.config['duration'],
    ));
  }

  @override
  void logRepBasedDrill({required int makes}) {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      makes: makes,
    ));
  }

  @override
  void logMakeTargetTimedDrill({required int elapsedSeconds}) {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      elapsedSeconds: elapsedSeconds,
      makes: currentDrill!.config['targetMakes'],
    ));
  }

  @override
  void endWorkout() {
    _blueprint = null;
    _currentDrillIndex = 0;
    _sessionResults.clear();
    notifyListeners();
  }

  @override
  Future<void> savePartialWorkout() async {
    endWorkout();
  }

  @override
  void discardWorkout() {
    endWorkout();
  }

  @override
  void logMake() {
    if (currentDrill == null) return;
    final drillId = currentDrill!.drillId;
    final existingResultIndex =
        _sessionResults.indexWhere((r) => r.drillId == drillId);
    if (existingResultIndex != -1) {
      final existingResult = _sessionResults[existingResultIndex];
      final updatedResult = DrillResult(
        drillId: drillId,
        makes: (existingResult.makes ?? 0) + 1,
        elapsedSeconds: existingResult.elapsedSeconds,
      );
      _sessionResults[existingResultIndex] = updatedResult;
      lastLoggedResult = updatedResult;
    } else {
      final newResult = DrillResult(drillId: drillId, makes: 1);
      _sessionResults.add(newResult);
      lastLoggedResult = newResult;
    }
    notifyListeners();
  }
}
