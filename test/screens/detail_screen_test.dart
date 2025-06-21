import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/detail/workout_detail_screen.dart';

void main() {
  // Create a mock WorkoutBlueprint to use in tests.
  final mockWorkout = WorkoutBlueprint(
    id: 'mock-workout-1',
    name: 'Mock Foundational Workout',
    objective: 'To test the detail screen UI.',
    estimatedDuration: 45,
    drills: [
      Drill(
        drillId: 'd1',
        name: 'Drill 1: Mock Dribbling',
        description: 'A mock drill for dribbling.',
        type: 'TIMED',
        config: {'duration': 300},
      ),
      Drill(
        drillId: 'd2',
        name: 'Drill 2: Mock Shooting',
        description: 'A mock drill for shooting.',
        type: 'REP_BASED',
        config: {'reps': 10, 'sets': 3},
      ),
      Drill(
        drillId: 'd3',
        name: 'Drill 3: Mock Finishing',
        description: 'A mock drill for finishing.',
        type: 'MAKE_TARGET_TIMED',
        config: {'makes': 10},
      ),
    ],
  );

  testWidgets('WorkoutDetailScreen displays all workout information correctly',
      (WidgetTester tester) async {
    // Pump the WorkoutDetailScreen widget with the mock data.
    await tester.pumpWidget(MaterialApp(
      home: WorkoutDetailScreen(workout: mockWorkout),
    ));

    // Verify that the workout name (in app bar and body) is displayed.
    expect(find.text(mockWorkout.name.toUpperCase()), findsOneWidget);
    expect(find.text(mockWorkout.name), findsOneWidget);

    // Verify that the workout objective is displayed.
    expect(find.text(mockWorkout.objective), findsOneWidget);

    // Verify that all drill names and descriptions are displayed.
    for (final drill in mockWorkout.drills) {
      expect(find.text(drill.name), findsOneWidget);
      expect(find.text(drill.description), findsOneWidget);
    }

    // Verify the "Start Workout" button is present.
    expect(find.widgetWithText(ElevatedButton, 'Start Workout'), findsOneWidget);
  });
}
