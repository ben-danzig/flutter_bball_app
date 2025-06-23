import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';

class TimedDrillWidget extends StatefulWidget {
  final Drill drill;

  const TimedDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  _TimedDrillWidgetState createState() => _TimedDrillWidgetState();
}

class _TimedDrillWidgetState extends State<TimedDrillWidget> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.drill.config['duration']!;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        Provider.of<WorkoutState>(context, listen: false).nextDrill();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF1f2937), // Medium Gray
              width: 15,
            ),
          ),
          child: Center(
            child: Text(
              _formatDuration(_remainingSeconds),
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                color: Colors.white,
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
