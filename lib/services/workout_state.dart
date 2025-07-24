import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/drill_result.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/services/audio_service.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/workout_session_service.dart';
import 'package:flutter_bball_app/utils/device_id_util.dart';

class WorkoutState extends ChangeNotifier {
  WorkoutBlueprint? _blueprint;
  int _currentDrillIndex = 0;
  bool _isPaused = false;
  final List<DrillResult> _sessionResults = [];
  int _resetDrillCounter = 0;
  final AudioService _audioService = AudioService();
  SettingsService? _settingsService;

  // Public getters to safely access the state
  bool get isWorkoutStarted => _blueprint != null;
  bool get isWorkoutComplete => _blueprint != null && _currentDrillIndex >= totalDrills;
  WorkoutBlueprint? get workoutBlueprint => _blueprint;
  bool get isPaused => _isPaused;
  Drill? get currentDrill {
    if (_blueprint == null || _currentDrillIndex >= _blueprint!.drills.length) {
      return null;
    }
    return _blueprint!.drills[_currentDrillIndex];
  }

  int get totalDrills => _blueprint?.drills.length ?? 0;
  List<DrillResult> get results => _sessionResults;
  int get currentDrillIndex => _currentDrillIndex;
  int get resetDrillCounter => _resetDrillCounter;

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

  void setSettingsService(SettingsService settingsService) {
    _settingsService = settingsService;
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  // Method to start a new workout
  void startWorkout(WorkoutBlueprint blueprint) {
    _blueprint = blueprint;
    _currentDrillIndex = 0;
    _sessionResults.clear();

    // Announce the first drill
    _announceDrill();

    // This is the key method from ChangeNotifier. It tells all listening
    // widgets that the state has changed and they need to rebuild.
    notifyListeners();
  }

  // Method to advance to the next drill
  void nextDrill() {
    if (_currentDrillIndex < totalDrills) {
      _currentDrillIndex++;
      
      // Announce the new drill if not complete
      if (!isWorkoutComplete) {
        _announceDrill();
      }
      
      notifyListeners();
    }
  }

  // Helper method to announce drill details
  void _announceDrill() {
    if (_settingsService == null || currentDrill == null) return;

    List<String> announcements = [];

    // Announce drill name
    if (_settingsService!.announceDrillName) {
      announcements.add('Next drill: ${currentDrill!.name}');
    }

    // Announce drill description
    if (_settingsService!.announceDrillDescription && currentDrill!.description.isNotEmpty) {
      announcements.add(currentDrill!.description);
    }

    // Announce target makes for applicable drill types
    if (_settingsService!.announceDrillTargetMakes) {
      if (currentDrill!.type == 'REP_BASED' && currentDrill!.config['reps'] != null) {
        announcements.add('Complete ${currentDrill!.config['reps']} repetitions');
      } else if (currentDrill!.type == 'MAKE_TARGET_TIMED' && currentDrill!.config['targetMakes'] != null) {
        announcements.add('Make ${currentDrill!.config['targetMakes']} shots');
      }
    }

    // Speak all announcements as one string
    if (announcements.isNotEmpty) {
      _audioService.speak(announcements.join('. '));
    }
  }

  // Method to log the result of a completed drill
  void _logDrillResult(DrillResult result) {
    _sessionResults.add(result);
  }

  void logTimedDrill() {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      elapsedSeconds: currentDrill!.config['duration'],
    ));
    notifyListeners();
  }

  void logRepBasedDrill({required int makes}) {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      makes: makes,
    ));
    notifyListeners();
  }

  void logMakeTargetTimedDrill({required int elapsedSeconds}) {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      elapsedSeconds: elapsedSeconds,
      makes: currentDrill!.config['targetMakes'],
    ));
    notifyListeners();
  }

  void logReadAndReactDrill({required int totalReps}) {
    if (currentDrill == null) return;
    _logDrillResult(DrillResult(
      drillId: currentDrill!.drillId,
      reps: totalReps,
    ));
    notifyListeners();
  }

  // Method to end the workout and reset the state
  void endWorkout() {
    _blueprint = null;
    _currentDrillIndex = 0;
    // Results are cleared when a new workout starts
    notifyListeners();
  }

  // Method to save partial workout progress
  Future<void> savePartialWorkout() async {
    if (_blueprint == null || _sessionResults.isEmpty) {
      endWorkout();
      return;
    }

    final deviceId = await getDeviceId();
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutBlueprint: _blueprint!,
      results: List.from(_sessionResults),
      completedAt: DateTime.now(),
      isPartial: true,
      deviceId: deviceId,
    );

    await WorkoutSessionService.instance.addSession(session);
    endWorkout();
  }

  // Method to discard workout without saving
  void discardWorkout() {
    endWorkout();
  }

  // Go to the previous drill (if not at the first drill)
  void previousDrill() {
    if (_currentDrillIndex > 0) {
      _currentDrillIndex--;
      _announceDrill();
      notifyListeners();
    }
  }

  // Reset the current drill (widgets should listen and reset their local state)
  void resetCurrentDrill() {
    _resetDrillCounter++;
    // Announce the drill again when resetting
    _announceDrill();
    // This method notifies listeners so drill widgets can reset their local state (timer, makes, etc.)
    notifyListeners();
  }
}
