import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import '../../../widgets/layout/split_priority_layout.dart';
import '../../../widgets/layout/primary_action_bar.dart';
import '../../../widgets/layout/secondary_control_bar.dart';
import '../../../widgets/layout/large_timer_display.dart';
import '../../../widgets/layout/responsive_content_area.dart';
import '../../../utils/drill_types.dart';
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
    return Consumer<WorkoutState>(
      builder: (context, workoutState, child) {
        // Calculate progress based on reps completed
        final progress = _totalReps > 0 ? (_currentRep - 1) / _totalReps : 0.0;

        return SplitPriorityLayout(
          // Primary Action Bar - READ_AND_REACT drills have no primary action (auto-complete)
          primaryActionBar: PrimaryActionBar(
            drillType: DrillType.readAndReact,
            nextDrillName: workoutState.nextDrillName,
            onPrimaryAction: null, // READ_AND_REACT drills auto-complete
            isPrimaryActionEnabled: false,
          ),
          
          // Content Area - Timer Display with Rep Counter
          content: ResponsiveContentArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large Timer Display
                LargeTimerDisplay(
                  seconds: _remainingSeconds > 0 ? _remainingSeconds : 1,
                  title: widget.drill.name.toUpperCase(),
                  subtitle: null, // We'll show rep count separately for better layout
                  textColor: Colors.white,
                ),
                
                const SizedBox(height: 40),
                
                // Rep Counter
                Text(
                  'REP $_currentRep / $_totalReps',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9ca3af),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Drill description/instructions
                if (widget.drill.description.isNotEmpty) ...[
                  Text(
                    widget.drill.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF9ca3af),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
                
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1f2937),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF3b82f6),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _remainingSeconds > 5 
                            ? Icons.accessibility_new 
                            : Icons.flash_on,
                        color: _remainingSeconds > 5 
                            ? const Color(0xFF10b981) 
                            : const Color(0xFFf59e0b),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _remainingSeconds > 5 
                            ? 'Get ready for the cue...' 
                            : 'Cue incoming!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _remainingSeconds > 5 
                              ? const Color(0xFF10b981) 
                              : const Color(0xFFf59e0b),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Secondary Control Bar - Universal workout controls
          secondaryControlBar: SecondaryControlBar(
            isPaused: workoutState.isPaused,
            onTogglePause: workoutState.togglePause,
            onPreviousDrill: workoutState.previousDrill,
            onNextDrill: workoutState.nextDrill,
            onEndWorkout: () => _showEndWorkoutDialog(context, workoutState),
            onResetCurrentDrill: workoutState.resetCurrentDrill,
          ),
          
          // Progress indication
          showProgressIndicator: true,
          progress: progress,
        );
      },
    );
  }

  void _showEndWorkoutDialog(BuildContext context, WorkoutState workoutState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1f2937),
          title: const Text(
            'End Workout?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'You can save your progress so far or discard this workout session.',
            style: TextStyle(color: Color(0xFF9ca3af)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9ca3af)),
              ),
            ),
            TextButton(
              onPressed: () {
                workoutState.discardWorkout();
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Discard',
                style: TextStyle(color: Color(0xFFef4444)),
              ),
            ),
            TextButton(
              onPressed: () {
                workoutState.savePartialWorkout();
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Save Progress',
                style: TextStyle(color: Color(0xFF3b82f6)),
              ),
            ),
          ],
        );
      },
    );
  }
}