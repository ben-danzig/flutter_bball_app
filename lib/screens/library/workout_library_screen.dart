import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/repositories/workout_repository.dart';

class WorkoutLibraryScreen extends StatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  State<WorkoutLibraryScreen> createState() => _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends State<WorkoutLibraryScreen> {
  // A Future to hold the result of our repository call
  late Future<WorkoutBlueprint> _workoutBlueprintFuture;
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  @override
  void initState() {
    super.initState();
    // Start loading the data as soon as the widget is created
    _workoutBlueprintFuture = _workoutRepository.getWorkoutBlueprint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // For status bar spacing
            const Text(
              'Workouts',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const Text(
              'Choose a workout to start your session.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // FutureBuilder handles the loading/error/success states for us
            FutureBuilder<WorkoutBlueprint>(
              future: _workoutBlueprintFuture,
              builder: (context, snapshot) {
                // State 1: Still loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // State 2: Error loading data
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // State 3: Data loaded successfully
                if (snapshot.hasData) {
                  final blueprint = snapshot.data!;
                  return _WorkoutCard(blueprint: blueprint);
                }
                // Default state (should not be reached)
                return const Center(child: Text('No workout found.'));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// A private helper widget for the card UI to keep the build method clean
class _WorkoutCard extends StatelessWidget {
  final WorkoutBlueprint blueprint;
  const _WorkoutCard({required this.blueprint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blueprint.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF60A5FA), // Light Blue
            ),
          ),
          const SizedBox(height: 8),
          Text(
            blueprint.objective,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            '${blueprint.estimatedDuration} MINS • ${blueprint.drills.length} DRILLS',
            style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}