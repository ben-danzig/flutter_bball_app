import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/widgets/active_drill_layout.dart';
import 'package:flutter_bball_app/screens/active/widgets/make_target_timed_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/rep_based_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutState>(
      builder: (context, workoutState, child) {
        if (!workoutState.isWorkoutStarted) {
          return const Scaffold(
            backgroundColor: Color(0xFF111827),
            body: Center(
                child: Text('No active workout.',
                    style: TextStyle(color: Colors.white))),
          );
        }

        final drill = workoutState.currentDrill;
        if (drill == null) {
          // This can happen when the workout is finished
          // We'll navigate to a summary screen later.
          return const Scaffold(
            backgroundColor: Color(0xFF111827),
            body: Center(
                child: Text('Workout Complete!',
                    style: TextStyle(color: Colors.white, fontSize: 24))),
          );
        }

        return ActiveDrillLayout(
          drillName: drill.name,
          nextDrillName: workoutState.nextDrillName,
          progress: workoutState.workoutProgress,
          child: _buildDrillView(drill),
        );
      },
    );
  }

  // This method acts as a router to select the correct UI for the drill type
  Widget _buildDrillView(Drill drill) {
    switch (drill.type) {
      case 'TIMED':
        return TimedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'REP_BASED':
        return RepBasedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'MAKE_TARGET_TIMED':
        return MakeTargetTimedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      default:
        return Center(child: Text('Unknown drill type: ${drill.type}'));
    }
  }
}

// All placeholder widgets have been replaced.
