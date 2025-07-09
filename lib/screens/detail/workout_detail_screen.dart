import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/active_workout_screen.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutBlueprint workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late List<Map<String, dynamic>> drillConfigs;

  @override
  void initState() {
    super.initState();
    // Make a copy of each drill's config so we can edit in memory
    drillConfigs = widget.workout.drills.map((d) => Map<String, dynamic>.from(d.config)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(widget.workout.name),
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
                    widget.workout.name.toUpperCase(),
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFf9fafb),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.workout.objective,
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
                final drill = widget.workout.drills[index];
                final config = drillConfigs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        if (drill.type == 'READ_AND_REACT') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Number of Intervals', style: TextStyle(color: Colors.white)),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      initialValue: config['reps']?.toString() ?? '10',
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF222b3a),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onChanged: (val) {
                                        final v = int.tryParse(val) ?? 1;
                                        setState(() {
                                          config['reps'] = v;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Interval Time (seconds)', style: TextStyle(color: Colors.white)),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      initialValue: config['intervalSeconds']?.toString() ?? '20',
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF222b3a),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onChanged: (val) {
                                        final v = int.tryParse(val) ?? 1;
                                        setState(() {
                                          config['intervalSeconds'] = v;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              childCount: widget.workout.drills.length,
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
                  // Create a new WorkoutBlueprint with updated configs
                  final updatedDrills = [
                    for (int i = 0; i < widget.workout.drills.length; i++)
                      Drill(
                        drillId: widget.workout.drills[i].drillId,
                        name: widget.workout.drills[i].name,
                        description: widget.workout.drills[i].description,
                        type: widget.workout.drills[i].type,
                        config: Map<String, dynamic>.from(drillConfigs[i]),
                      )
                  ];
                  final updatedWorkout = WorkoutBlueprint(
                    id: widget.workout.id,
                    name: widget.workout.name,
                    objective: widget.workout.objective,
                    estimatedDuration: widget.workout.estimatedDuration,
                    drills: updatedDrills,
                  );
                  Provider.of<WorkoutState>(context, listen: false)
                      .startWorkout(updatedWorkout);
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
