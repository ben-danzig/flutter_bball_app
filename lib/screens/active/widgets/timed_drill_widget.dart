import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import '../../../utils/widgets/countdown_timer_widget.dart';

class TimedDrillWidget extends StatefulWidget {
  final Drill drill;

  const TimedDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  _TimedDrillWidgetState createState() => _TimedDrillWidgetState();
}

class _TimedDrillWidgetState extends State<TimedDrillWidget> {
  int? _lastDrillIndex;
  int? _lastResetCounter;
  late int _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.drill.config['duration']!;
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
      setState(() {
        _currentDuration = widget.drill.config['duration']!;
      });
      _lastResetCounter = resetCounter;
    } else {
      _lastDrillIndex = currentDrillIndex;
      _lastResetCounter = resetCounter;
    }
  }

  void _onTimerComplete() {
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    workoutState.logTimedDrill();
    workoutState.nextDrill();
  }

  void _onTimeEdit(int newDuration) {
    setState(() {
      _currentDuration = newDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CountdownTimerWidget(
      durationSeconds: _currentDuration,
      onComplete: _onTimerComplete,
      isPaused: Provider.of<WorkoutState>(context).isPaused,
      showTapToEdit: true,
      onTimeEdit: _onTimeEdit,
      title: widget.drill.name,
      subtitle: widget.drill.description,
    );
  }
}
