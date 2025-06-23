import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
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
        // If no workout is active, show an empty state (or navigate back).
        // This is a safeguard.
        if (!workoutState.isWorkoutStarted) {
          return const Scaffold(
            body: Center(child: Text('No active workout.')),
          );
        }

        final drill = workoutState.currentDrill!;

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // This is the top "context" bar from our mockups
                const SizedBox(height: 40),
                const Text(
                  'UP NEXT: Drill Name Here', // We will make this dynamic later
                  style: TextStyle(color: Colors.grey),
                ),

                // The main display area, which will change dynamically
                Expanded(
                  child: _buildDrillView(drill),
                ),

                // This is the bottom progress bar from our mockups
                const LinearProgressIndicator(value: 0.5), // Placeholder value
                const SizedBox(height: 16),
              ],
            ),
          ),
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
