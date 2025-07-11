import 'dart:async';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

/// Game Timer Service for managing basketball game countdown timers.
/// 
/// This service provides a countdown timer with controls for starting, pausing,
/// resuming, and resetting. It triggers callbacks when the timer completes and
/// plays an audio cue.
/// 
/// Example usage:
/// ```dart
/// final timer = GameTimerService();
/// timer.onTimerComplete(() => print('Game Over!'));
/// timer.startTimer(300); // Start 5-minute timer
/// ```
class GameTimerService extends ChangeNotifier {
  static final GameTimerService _instance = GameTimerService._internal();
  factory GameTimerService() => _instance;
  GameTimerService._internal();

  Timer? _timer;
  int _totalSeconds = 300; // Default 5 minutes
  int _remainingSeconds = 300;
  bool _isRunning = false;
  final List<Function> _completionCallbacks = [];
  final AudioService _audioService = AudioService();

  // Stream controller for real-time updates
  final StreamController<int> _timerStream = StreamController<int>.broadcast();

  /// Stream that emits the current remaining seconds in real-time
  Stream<int> get timerStream => _timerStream.stream;

  /// Returns the current time remaining in seconds
  int getTimeRemaining() => _remainingSeconds;

  /// Returns whether the timer is currently running
  bool isRunning() => _isRunning;

  /// Starts the timer for the specified duration (default: 300 seconds)
  void startTimer([int seconds = 300]) {
    _timer?.cancel();
    _totalSeconds = seconds;
    _remainingSeconds = seconds;
    _isRunning = true;
    _startTicking();
    notifyListeners();
  }

  /// Pauses the countdown
  void pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }

  /// Resumes the countdown from where it left off
  void resumeTimer() {
    if (!_isRunning && _remainingSeconds > 0) {
      _isRunning = true;
      _startTicking();
      notifyListeners();
    }
  }

  /// Resets the timer to the specified duration (default: 300 seconds)
  void resetTimer([int seconds = 300]) {
    _timer?.cancel();
    _totalSeconds = seconds;
    _remainingSeconds = seconds;
    _isRunning = false;
    _timerStream.add(_remainingSeconds);
    notifyListeners();
  }

  /// Registers a callback to be called when the timer reaches zero
  void onTimerComplete(Function callback) {
    _completionCallbacks.add(callback);
  }

  /// Plays the bell sound (audio cue)
  Future<void> playAudioCue() async {
    await _audioService.speak('Time is up!');
  }

  /// Internal method to start the timer ticking
  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _timerStream.add(_remainingSeconds);
        notifyListeners();
      } else {
        // Timer completed
        _timer?.cancel();
        _isRunning = false;
        _timerStream.add(0);
        notifyListeners();
        
        // Trigger completion callbacks
        for (final callback in _completionCallbacks) {
          callback();
        }
        
        // Play audio cue
        playAudioCue();
      }
    });
  }

  /// Cleans up resources
  void dispose() {
    _timer?.cancel();
    _timerStream.close();
    super.dispose();
  }

  /// Gets the elapsed time in seconds
  int getElapsedSeconds() => _totalSeconds - _remainingSeconds;

  /// Gets the total duration set for the timer
  int getTotalSeconds() => _totalSeconds;

  /// Clears all completion callbacks
  void clearCallbacks() {
    _completionCallbacks.clear();
  }

  /// Removes a specific callback
  void removeCallback(Function callback) {
    _completionCallbacks.remove(callback);
  }
}