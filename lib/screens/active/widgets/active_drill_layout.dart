import 'package:flutter/material.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';
import '../../../utils/widgets/pause_resume_button.dart';

class ActiveDrillLayout extends StatelessWidget {
  final String drillName;
  final String? nextDrillName;
  final Widget child;
  final double progress;

  const ActiveDrillLayout({
    super.key,
    required this.drillName,
    required this.nextDrillName,
    required this.child,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Top Bar
              Text(
                'UP NEXT: ${nextDrillName ?? "Workout Complete"}',
                style: const TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
              ),
              const SizedBox(height: 20),

              // 2. Main Content (the specific drill widget)
              Expanded(
                child: child,
              ),

              // 3. Bottom Bar
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1f2937),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev button with tap and long-press
                  Tooltip(
                    message: 'Long press to reset drill',
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<WorkoutState>(context, listen: false)
                            .previousDrill();
                      },
                      onLongPress: () {
                        Provider.of<WorkoutState>(context, listen: false)
                            .resetCurrentDrill();
                      },
                      child: const Text(
                        '< PREV',
                        style: TextStyle(
                          color: Color(0xFF9ca3af),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Consumer<WorkoutState>(
                    builder: (context, workoutState, child) {
                      return PauseResumeButton(
                        isPaused: workoutState.isPaused,
                        onTogglePause: () {
                          workoutState.togglePause();
                        },
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => _showEndWorkoutDialog(context),
                    child: const Text(
                      'END',
                      style: TextStyle(
                          color: Color(0xFFef4444),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<WorkoutState>(context, listen: false)
                          .nextDrill();
                    },
                    child: const Text(
                      'SKIP >',
                      style: TextStyle(
                          color: Color(0xFF9ca3af),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1f2937),
          title: const Text(
            'End Workout?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'You can save your progress so far or discard this workout session.',
            style: TextStyle(color: Color(0xFF9ca3af)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9ca3af)),
              ),
            ),
            TextButton(
              onPressed: () {
                final workoutState = Provider.of<WorkoutState>(context, listen: false);
                workoutState.discardWorkout();
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Discard',
                style: TextStyle(color: Color(0xFFef4444)),
              ),
            ),
            TextButton(
              onPressed: () {
                final workoutState = Provider.of<WorkoutState>(context, listen: false);
                workoutState.savePartialWorkout();
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Save Progress',
                style: TextStyle(color: Color(0xFF3b82f6)),
              ),
            ),
          ],
        );
      },
    );
  }
}
