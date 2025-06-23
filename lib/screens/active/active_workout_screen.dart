import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_bball_app/models/drill.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutState>(
      builder: (context, workoutState, child) {
        final drill = workoutState.currentDrill;
        if (drill == null) {
          return const Scaffold(
            body: Center(
              child: Text("Workout Complete!"),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(drill.name),
          ),
          body: Center(
            child: _buildDrillWidget(drill),
          ),
        );
      },
    );
  }

  Widget _buildDrillWidget(Drill drill) {
    switch (drill.type) {
      case 'TIMED':
        return Text('Timer UI for ${drill.name}');
      case 'REP_BASED':
        return Text('Rep Counter UI for ${drill.name}');
      case 'MAKE_TARGET_TIMED':
        return Text('Make Target Timed UI for ${drill.name}');
      default:
        return Text('Unknown drill type');
    }
  }
}
