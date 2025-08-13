import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import '../../../widgets/layout/split_priority_layout.dart';
import '../../../widgets/layout/primary_action_bar.dart';
import '../../../widgets/layout/secondary_control_bar.dart';
import '../../../widgets/layout/large_timer_display.dart';
import '../../../widgets/layout/responsive_content_area.dart';
import '../../../utils/drill_types.dart';
import 'time_picker_dialog.dart' as custom_picker;

class MakeTargetTimedDrillWidget extends StatefulWidget {
  final Drill drill;

  const MakeTargetTimedDrillWidget({super.key, required this.drill});

  @override
  _MakeTargetTimedDrillWidgetState createState() => _MakeTargetTimedDrillWidgetState();
}

class _MakeTargetTimedDrillWidgetState extends State<MakeTargetTimedDrillWidget> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  int _currentMakes = 0;
  bool _isComplete = false;
  int? _lastDrillIndex;
  int? _lastResetCounter;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
        _elapsedSeconds = 0;
        _currentMakes = 0;
        _isComplete = false;
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
      if (!_isComplete) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _incrementMakes() {
    if (_isComplete) return;

    setState(() {
      _currentMakes++;
      if (_currentMakes >= widget.drill.config['targetMakes']!) {
        _isComplete = true;
        _timer.cancel();
      }
    });
  }

  void _logAllMakes() {
    setState(() {
      _currentMakes = widget.drill.config['targetMakes']!;
      _isComplete = true;
      _timer.cancel();
    });
  }

  void _finishDrill() {
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    workoutState.logMakeTargetTimedDrill(elapsedSeconds: _elapsedSeconds);
    workoutState.nextDrill();
  }

  Future<void> _showTimePickerDialog() async {
    if (_isComplete) return;
    
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    final wasPaused = workoutState.isPaused;
    
    if (!wasPaused) {
      workoutState.togglePause();
    }
    
    final result = await showDialog<int>(
      context: context,
      builder: (context) => custom_picker.TimePickerDialog(initialSeconds: _elapsedSeconds),
    );
    
    if (result != null) {
      setState(() {
        _elapsedSeconds = result;
      });
    }
    
    if (!wasPaused) {
      workoutState.togglePause();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetMakes = widget.drill.config['targetMakes']!;

    return Consumer<WorkoutState>(
      builder: (context, workoutState, child) {
        // Calculate progress based on makes completed
        final progress = targetMakes > 0 ? _currentMakes / targetMakes : 0.0;

        return SplitPriorityLayout(
          // Primary Action Bar - Show FINISH DRILL when complete
          primaryActionBar: PrimaryActionBar(
            drillType: DrillType.makeTargetTimed,
            nextDrillName: workoutState.nextDrillName,
            onPrimaryAction: _isComplete ? _finishDrill : null,
            isPrimaryActionEnabled: _isComplete,
          ),
          
          // Content Area - Timer Display + Make Controls
          content: ResponsiveContentArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large Timer Display
                GestureDetector(
                  onTap: _showTimePickerDialog,
                  child: LargeTimerDisplay(
                    seconds: _elapsedSeconds,
                    title: widget.drill.name.toUpperCase(),
                    subtitle: 'MAKES: $_currentMakes / $targetMakes',
                    textColor: _isComplete ? Colors.greenAccent : Colors.white,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Make Controls - Only show when not complete
                if (!_isComplete) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1f2937),
                          minimumSize: const Size(120, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: _incrementMakes,
                        child: const Text(
                          '+1 MAKE',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          minimumSize: const Size(120, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: _logAllMakes,
                        child: const Text(
                          'LOG ALL',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    widget.drill.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9ca3af),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                // Completion message
                if (_isComplete) ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Target Completed!\nTap FINISH DRILL above to continue.',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
