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
import '../widgets/time_picker_dialog.dart' as custom_picker;

class TimedDrillWidget extends StatefulWidget {
  final Drill drill;

  const TimedDrillWidget({super.key, required this.drill});

  @override
  _TimedDrillWidgetState createState() => _TimedDrillWidgetState();
}

class _TimedDrillWidgetState extends State<TimedDrillWidget> {
  late Timer _timer;
  int? _lastDrillIndex;
  int? _lastResetCounter;
  late int _currentDuration;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.drill.config['duration'] ?? 60; // Default to 60 seconds
    _remainingSeconds = _currentDuration;
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
        _currentDuration = widget.drill.config['duration'] ?? 60;
        _remainingSeconds = _currentDuration;
      });
      _startTimer();
      _lastResetCounter = resetCounter;
    } else {
      _lastDrillIndex = currentDrillIndex;
      _lastResetCounter = resetCounter;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final workoutState = Provider.of<WorkoutState>(context, listen: false);
      if (workoutState.isPaused) {
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    workoutState.logTimedDrill();
    workoutState.nextDrill();
  }

  void _onTimeEdit(int newDuration) {
    setState(() {
      _currentDuration = newDuration;
      _remainingSeconds = newDuration;
    });
  }

  Future<void> _showTimePickerDialog() async {
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    final wasPaused = workoutState.isPaused;
    
    // Pause workout if not already paused
    if (!wasPaused) {
      workoutState.togglePause();
    }
    
    final result = await showDialog<int>(
      context: context,
      builder: (context) => custom_picker.TimePickerDialog(initialSeconds: _remainingSeconds),
    );
    
    if (result != null) {
      _onTimeEdit(result);
    }
    
    // Resume workout if it wasn't paused before
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
    return Consumer<WorkoutState>(
      builder: (context, workoutState, child) {
        // Calculate progress: (initial duration - remaining) / initial duration
        final progress = _currentDuration > 0 
            ? (_currentDuration - _remainingSeconds) / _currentDuration 
            : 0.0;

        return SplitPriorityLayout(
          // Primary Action Bar - TIMED drills have no primary action
          primaryActionBar: PrimaryActionBar(
            drillType: DrillType.timed,
            nextDrillName: workoutState.nextDrillName,
            onPrimaryAction: null, // TIMED drills auto-complete
            isPrimaryActionEnabled: false,
          ),
          
          // Content Area - Large Timer Display
          content: ResponsiveContentArea(
            child: GestureDetector(
              onTap: _showTimePickerDialog,
              child: LargeTimerDisplay(
                seconds: _remainingSeconds,
                title: widget.drill.name.toUpperCase(),
                subtitle: widget.drill.description.isNotEmpty ? widget.drill.description : null,
                textColor: Colors.white,
              ),
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
