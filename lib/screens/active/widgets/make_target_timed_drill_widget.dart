import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';

class MakeTargetTimedDrillWidget extends StatefulWidget {
  final Drill drill;

  const MakeTargetTimedDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  _MakeTargetTimedDrillWidgetState createState() => _MakeTargetTimedDrillWidgetState();
}

class _MakeTargetTimedDrillWidgetState extends State<MakeTargetTimedDrillWidget> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  int _currentMakes = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetMakes = widget.drill.config['targetMakes']!;

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
        const SizedBox(height: 20),
        Text(
          _formatDuration(_elapsedSeconds),
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w900,
            color: _isComplete ? Colors.greenAccent : Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MAKES',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
            children: [
              TextSpan(
                text: '$_currentMakes',
                style:
                    const TextStyle(fontSize: 72, fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: ' / $targetMakes',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.drill.description,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF9ca3af),
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        if (!_isComplete)
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
                child: const Text('+1 MAKE',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                onPressed: () {
                  setState(() {
                    _currentMakes = widget.drill.config['targetMakes']!;
                    _isComplete = true;
                    _timer.cancel();
                  });
                },
                child: const Text('LOG ALL',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(150, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () {
              Provider.of<WorkoutState>(context, listen: false).nextDrill();
            },
            child: const Text('FINISH DRILL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
