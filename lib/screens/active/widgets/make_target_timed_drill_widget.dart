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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
          widget.drill.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          _formatDuration(_elapsedSeconds),
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: _isComplete ? Colors.green : const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '$_currentMakes / $targetMakes MAKES',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 40),
        if (!_isComplete)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: _incrementMakes,
            child: const Text('+1 MAKE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: () {
              Provider.of<WorkoutState>(context, listen: false).nextDrill();
            },
            child: const Text('FINISH DRILL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
