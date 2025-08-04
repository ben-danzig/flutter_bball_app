import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/repositories/workout_repository.dart';
import 'package:flutter_bball_app/screens/detail/workout_detail_screen.dart';
import 'package:flutter_bball_app/screens/history/workout_history_screen.dart';

class WorkoutLibraryScreen extends StatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  State<WorkoutLibraryScreen> createState() => _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends State<WorkoutLibraryScreen> {
  late Future<List<WorkoutBlueprint>> _workoutBlueprintsFuture;
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  @override
  void initState() {
    super.initState();
    _workoutBlueprintsFuture = _workoutRepository.getAllWorkoutBlueprints();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workouts',
                    style: textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFFf9fafb),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkoutHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a workout to start your session.',
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF9ca3af),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<WorkoutBlueprint>>(
                  future: _workoutBlueprintsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.white)),
                              const SizedBox(height: 16),
                              Text('Stack trace: ${snapshot.stackTrace}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ));
                    }
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final workouts = snapshot.data!;
                      return ListView.builder(
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WorkoutDetailScreen(workout: workout),
                                  ),
                                );
                              },
                              child: _WorkoutCard(workout: workout),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(
                        child: Text('No workouts found.',
                            style: TextStyle(color: Colors.white)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutBlueprint workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4b5563)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.name,
            style: textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF3b82f6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            workout.objective,
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9ca3af),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${workout.estimatedDuration} MINS • ${workout.drills.length} DRILLS',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9ca3af),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
