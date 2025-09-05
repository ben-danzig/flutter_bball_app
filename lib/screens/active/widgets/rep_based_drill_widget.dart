import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';
import '../../../widgets/layout/split_priority_layout.dart';
import '../../../widgets/layout/primary_action_bar.dart';
import '../../../widgets/layout/secondary_control_bar.dart';
import '../../../widgets/layout/responsive_content_area.dart';
import '../../../utils/drill_types.dart';

class RepBasedDrillWidget extends StatelessWidget {
  final Drill drill;

  const RepBasedDrillWidget({super.key, required this.drill});

  void _showLogSetDialog(BuildContext context, WorkoutState workoutState) {
    final makesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1f2937),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Log Your Set',
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'How many shots did you make?',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: makesController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    final makes = int.tryParse(makesController.text) ?? 0;
                    workoutState.logRepBasedDrill(makes: makes);
                    workoutState.nextDrill();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text(
                    'SAVE & CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetMakes = drill.config['targetMakes'];
    // We'll need to get the current makes from workoutState later
    const currentMakes = 0;

    return Consumer<WorkoutState>(
      builder: (context, workoutState, child) {
        // Calculate progress (placeholder for now)
        final progress = targetMakes != null && targetMakes > 0 
            ? currentMakes / targetMakes 
            : 0.0;

        return SplitPriorityLayout(
          // Primary Action Bar - Show LOG SET button
          primaryActionBar: PrimaryActionBar(
            drillType: DrillType.repBased,
            nextDrillName: workoutState.nextDrillName,
            onPrimaryAction: () => _showLogSetDialog(context, workoutState),
            isPrimaryActionEnabled: true, // Always enabled for rep-based drills
          ),
          
          // Content Area - Makes display and instructions
          content: ResponsiveContentArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drill name
                Text(
                  drill.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFf9fafb),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Makes counter display
                if (targetMakes != null) ...[
                  Text(
                    'MAKES',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(
                          text: '$currentMakes',
                          style: TextStyle(fontSize: 96, fontWeight: FontWeight.w900),
                        ),
                        TextSpan(
                          text: ' / $targetMakes',
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // No target - just show instruction
                  Icon(
                    Icons.sports_basketball,
                    size: 120,
                    color: Colors.grey[600],
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Instructions
                Text(
                  drill.description.isNotEmpty 
                      ? drill.description
                      : 'Complete your set, then tap LOG SET above to record your makes.',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF9ca3af),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Action hint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1f2937),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tap LOG SET above when finished',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Secondary Control Bar - Universal workout controls
          secondaryControlBar: SecondaryControlBar(
            isPaused: workoutState.isPaused,
            onTogglePause: workoutState.togglePause,
            onPreviousDrill: workoutState.previousDrill,
            onNextDrill: workoutState.nextDrill,
            onEndWorkout: () => _showEndWorkoutDialog(context, workoutState),
            onResetCurrentDrill: workoutState.resetCurrentDrill,
          ),
          
          // Progress indication
          showProgressIndicator: true,
          progress: progress,
        );
      },
    );
  }

  void _showEndWorkoutDialog(BuildContext context, WorkoutState workoutState) {
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
