import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/injury_log_screen.dart';
import 'package:flutter_bball_app/screens/active/widgets/make_target_timed_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/rep_based_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/read_and_react_drill_widget.dart';
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
              child: Text(
                'No active workout.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        if (workoutState.isWorkoutComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const InjuryLogScreen()),
            );
          });
          return const Scaffold(
            backgroundColor: Color(0xFF111827),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final drill = workoutState.currentDrill!;

        // Drill widgets now handle their own complete layout via SplitPriorityLayout
        // No need for ActiveDrillLayout wrapper anymore
        return _buildDrillView(drill);
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
      case 'READ_AND_REACT':
        return ReadAndReactDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      default:
        return const Scaffold(
          backgroundColor: Color(0xFF111827),
          body: Center(
            child: Text(
              'Unknown drill type. Please check your workout configuration.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }
}
