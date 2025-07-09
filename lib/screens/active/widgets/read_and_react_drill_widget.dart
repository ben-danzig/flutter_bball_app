import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';
import 'read_and_react_cue_overlay.dart';
import '../../../models/cue_action.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  int? _lastDrillIndex;
  int? _lastResetCounter;
  bool _isCueShowing = false;
  late List<CueAction> _actions;

  @override
  void initState() {
    super.initState();
    _intervalSeconds = widget.drill.config['intervalSeconds'] ?? 20;
    _totalReps = widget.drill.config['reps'] ?? 10;
    _remainingSeconds = _intervalSeconds;
    _initializeTts();
    // Parse actions from config, or use default
    final rawActions = widget.drill.config['actions'];
    if (rawActions is List && (rawActions).isNotEmpty) {
      _actions = (rawActions)
          .where((a) => a is Map)
          .map((a) => CueAction.fromJson(Map<String, dynamic>.from(a)))
          .toList();
    } else {
      _actions = _defaultActions();
    }
    _startTimer();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  List<CueAction> _defaultActions() => [
        CueAction(label: 'SHOOT', color: const Color(0xFF10B981), ttsPhrase: 'Shoot'),
        CueAction(label: 'DRIVE LEFT', icon: Icons.arrow_back, color: const Color(0xFFEAB308), ttsPhrase: 'Drive left'),
        CueAction(label: 'DRIVE RIGHT', icon: Icons.arrow_forward, color: const Color(0xFFEAB308), ttsPhrase: 'Drive right'),
      ];

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

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds == 1) {
        // Show direction cue overlay
        _showRandomDirectionCue();
      }
    });
  }

  Future<void> _showRandomDirectionCue() async {
    if (_isCueShowing) return;
    _isCueShowing = true;
    final cue = _actions[_random.nextInt(_actions.length)];
    await _flutterTts.speak(cue.ttsPhrase ?? cue.label);
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => ReadAndReactCueOverlay(cue: cue),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    _isCueShowing = false;

    // Move to next rep or finish
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    if (_currentRep < _totalReps) {
      setState(() {
        _currentRep++;
        _remainingSeconds = _intervalSeconds;
      });
    } else {
      _timer.cancel();
      workoutState.logReadAndReactDrill(totalReps: _totalReps);
      workoutState.nextDrill();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}