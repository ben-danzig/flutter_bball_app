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

  @override
  Widget build(BuildContext context) {
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
          '$_remainingSeconds',
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B82F6), // Bright Blue
          ),
        ),
        const SizedBox(height: 20),
        // Placeholder for future controls like pause/skip
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Example Button:
            // ElevatedButton(onPressed: () {}, child: Text("Pause")),
          ],
        )
      ],
    );
  }
}
