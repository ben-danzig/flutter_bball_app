import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/active/active_workout_screen.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutBlueprint workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(workout.name),
        backgroundColor: const Color(0xFF1f2937),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name.toUpperCase(),
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFf9fafb),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.objective,
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF9ca3af),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final drill = workout.drills[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1f2937),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFF4b5563)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drill.name,
                          style: textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFf9fafb),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          drill.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9ca3af),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: workout.drills.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b82f6),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Provider.of<WorkoutState>(context, listen: false)
                      .startWorkout(workout);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ActiveWorkoutScreen(),
                    ),
                  );
                },
                child: Text(
                  'Start Workout',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
