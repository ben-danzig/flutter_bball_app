import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';
import 'package:numberpicker/numberpicker.dart';

class TimedDrillWidget extends StatefulWidget {
  final Drill drill;

  const TimedDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  _TimedDrillWidgetState createState() => _TimedDrillWidgetState();
}

class _TimedDrillWidgetState extends State<TimedDrillWidget> {
  late Timer _timer;
  late int _remainingSeconds;
  int? _lastDrillIndex;
  int? _lastResetCounter;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.drill.config['duration']!;
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
        _remainingSeconds = widget.drill.config['duration']!;
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

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        workoutState.logTimedDrill();
        workoutState.nextDrill();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
            child: GestureDetector(
              onTap: () async {
                final workoutState = Provider.of<WorkoutState>(context, listen: false);
                final wasPaused = workoutState.isPaused;
                if (!wasPaused) {
                  workoutState.togglePause();
                }
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => _TimePickerDialog(initialSeconds: _remainingSeconds),
                );
                if (result != null) {
                  setState(() {
                    _remainingSeconds = result;
                  });
                }
                if (!wasPaused) {
                  workoutState.togglePause();
                }
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatDuration(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 300,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
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

class _TimePickerDialog extends StatefulWidget {
  final int initialSeconds;
  const _TimePickerDialog({Key? key, required this.initialSeconds}) : super(key: key);

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    minutes = widget.initialSeconds ~/ 60;
    seconds = (widget.initialSeconds % 60) - (widget.initialSeconds % 5);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1f2937),
      title: const Text('Set Timer', style: TextStyle(color: Colors.white)),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NumberPicker(
            value: minutes,
            minValue: 0,
            maxValue: 59,
            zeroPad: true,
            itemHeight: 60,
            onChanged: (value) => setState(() => minutes = value),
            textStyle: const TextStyle(color: Colors.white54, fontSize: 32),
            selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text(':', style: TextStyle(color: Colors.white, fontSize: 48)),
          NumberPicker(
            value: seconds,
            minValue: 0,
            maxValue: 55,
            step: 5,
            zeroPad: true,
            itemHeight: 60,
            onChanged: (value) => setState(() => seconds = value),
            textStyle: const TextStyle(color: Colors.white54, fontSize: 32),
            selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF9ca3af))),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(minutes * 60 + seconds);
          },
          child: const Text('Set', style: TextStyle(color: Color(0xFF3b82f6), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
