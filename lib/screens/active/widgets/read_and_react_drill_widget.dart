import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';

class ReadAndReactDrillWidget extends StatefulWidget {
  final Drill drill;

  const ReadAndReactDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  _ReadAndReactDrillWidgetState createState() => _ReadAndReactDrillWidgetState();
}

class _ReadAndReactDrillWidgetState extends State<ReadAndReactDrillWidget> {
  late Timer _timer;
  late int _intervalSeconds;
  int _remainingSeconds = 0;
  int _currentRep = 1;
  late int _totalReps;
  String? _currentDirection;
  bool _showingDirection = false;
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  int? _lastDrillIndex;
  int? _lastResetCounter;

  @override
  void initState() {
    super.initState();
    _intervalSeconds = widget.drill.config['intervalSeconds'] ?? 20;
    _totalReps = widget.drill.config['reps'] ?? 10;
    _remainingSeconds = _intervalSeconds;
    _initializeTts();
    _startTimer();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workoutState = Provider.of<WorkoutState>(context);
    final currentDrillIndex = workoutState.currentDrillIndex;
    final resetCounter = workoutState.resetDrillCounter;
    if (_lastDrillIndex == null) {
      _lastDrillIndex = currentDrillIndex;
      _lastResetCounter = resetCounter;
    } else if (_lastDrillIndex == currentDrillIndex && _lastResetCounter != resetCounter) {
      // Only reset if resetDrillCounter changed
      _timer.cancel();
      setState(() {
        _remainingSeconds = _intervalSeconds;
        _currentRep = 1;
        _currentDirection = null;
        _showingDirection = false;
      });
      _startTimer();
      _lastResetCounter = resetCounter;
    } else {
      _lastDrillIndex = currentDrillIndex;
      _lastResetCounter = resetCounter;
    }
  }

  void _startTimer() {
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (workoutState.isPaused) {
        return;
      }

      if (_showingDirection) {
        // Direction is showing for 2 seconds
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          // Move to next rep
          if (_currentRep < _totalReps) {
            setState(() {
              _currentRep++;
              _remainingSeconds = _intervalSeconds;
              _showingDirection = false;
              _currentDirection = null;
            });
          } else {
            // Drill complete
            _timer.cancel();
            workoutState.logReadAndReactDrill(totalReps: _totalReps);
            workoutState.nextDrill();
          }
        }
      } else {
        // Counting down interval
        if (_remainingSeconds > 1) {
          setState(() {
            _remainingSeconds--;
          });
        } else if (_remainingSeconds == 1) {
          // Show direction immediately instead of showing 0
          _showRandomDirection();
        }
      }
    });
  }

  void _showRandomDirection() async {
    final directions = ['SHOOT', 'DRIVE_LEFT', 'DRIVE_RIGHT'];
    final direction = directions[_random.nextInt(directions.length)];
    
    setState(() {
      _currentDirection = direction;
      _showingDirection = true;
      _remainingSeconds = 2; // Show direction for 2 seconds
    });

    // Speak the direction
    String speechText = '';
    switch (direction) {
      case 'SHOOT':
        speechText = 'Shoot';
        break;
      case 'DRIVE_LEFT':
        speechText = 'Drive left';
        break;
      case 'DRIVE_RIGHT':
        speechText = 'Drive right';
        break;
    }
    await _flutterTts.speak(speechText);
  }

  @override
  void dispose() {
    _timer.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  Widget _buildDirectionDisplay(BuildContext context) {
    if (_currentDirection == null) return const SizedBox.shrink();

    Color backgroundColor;
    Widget content;

    switch (_currentDirection) {
      case 'SHOOT':
        backgroundColor = const Color(0xFF10B981); // Green
        content = const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SHOOT',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        );
        break;
      case 'DRIVE_LEFT':
        backgroundColor = const Color(0xFFEAB308); // Yellow/Orange
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DRIVE',
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),
            Transform.rotate(
              angle: 0, // No rotation needed for left arrow
              child: const Icon(
                Icons.arrow_back,
                size: 100,
                color: Colors.black,
              ),
            ),
          ],
        );
        break;
      case 'DRIVE_RIGHT':
        backgroundColor = const Color(0xFFEAB308); // Yellow/Orange
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DRIVE',
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),
            Transform.rotate(
              angle: 0, // No rotation needed for right arrow
              child: const Icon(
                Icons.arrow_forward,
                size: 100,
                color: Colors.black,
              ),
            ),
          ],
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    // Make the cue take up the entire screen
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: backgroundColor,
      alignment: Alignment.center,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base: normal timer UI
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.drill.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf9fafb),
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatDuration(_remainingSeconds > 0 ? _remainingSeconds : 1),
                        style: const TextStyle(
                          fontSize: 200,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'REP $_currentRep / $_totalReps',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9ca3af),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.drill.description,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF9ca3af),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        // Overlay: full-screen cue
        if (_showingDirection)
          Positioned.fill(
            child: _buildDirectionDisplay(context),
          ),
      ],
    );
  }
}