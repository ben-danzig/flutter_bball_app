import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutBlueprint blueprint;

  const WorkoutDetailScreen({
    super.key,
    required this.blueprint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blueprint.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blueprint.name,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              blueprint.objective,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${blueprint.estimatedDuration} MINS • ${blueprint.drills.length} DRILLS',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Drills',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: blueprint.drills.length,
                itemBuilder: (context, index) {
                  final drill = blueprint.drills[index];
                  return ListTile(
                    title: Text(drill.name),
                    subtitle: Text(drill.description),
                    trailing: _buildDrillTypeIndicator(drill.type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillTypeIndicator(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'TIMED':
        icon = Icons.timer;
        color = Colors.blue;
        break;
      case 'REP_BASED':
        icon = Icons.repeat;
        color = Colors.green;
        break;
      case 'MAKE_TARGET_TIMED':
        icon = Icons.sports_basketball;
        color = Colors.orange;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(icon, color: color);
  }
}
