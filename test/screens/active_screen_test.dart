import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/active/active_workout_screen.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ActiveWorkoutScreen shows correct UI for timed drill',
      (WidgetTester tester) async {
    // 1. Create a mock WorkoutState
    final workoutState = WorkoutState();
    final blueprint = WorkoutBlueprint(
      id: 'test',
      name: 'Test Workout',
      objective: 'Test objective',
      estimatedDuration: 10,
      drills: [
        Drill(
          drillId: 'drill1',
          name: 'Timed Drill',
          description: 'A timed drill',
          type: 'TIMED',
          config: {'duration': 60},
        ),
      ],
    );
    workoutState.startWorkout(blueprint);

    // 2. Pump the widget with the provider
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: workoutState,
        child: const MaterialApp(
          home: ActiveWorkoutScreen(),
        ),
      ),
    );

    // 3. Verify the correct UI is shown
    expect(find.text('Timer UI for Timed Drill'), findsOneWidget);
    expect(find.text('Rep Counter UI for Timed Drill'), findsNothing);
  });

  testWidgets('ActiveWorkoutScreen shows correct UI for rep-based drill',
      (WidgetTester tester) async {
    // 1. Create a mock WorkoutState
    final workoutState = WorkoutState();
    final blueprint = WorkoutBlueprint(
      id: 'test',
      name: 'Test Workout',
      objective: 'Test objective',
      estimatedDuration: 10,
      drills: [
        Drill(
          drillId: 'drill2',
          name: 'Rep-Based Drill',
          description: 'A rep-based drill',
          type: 'REP_BASED',
          config: {'reps': 10, 'sets': 3},
        ),
      ],
    );
    workoutState.startWorkout(blueprint);

    // 2. Pump the widget with the provider
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: workoutState,
        child: const MaterialApp(
          home: ActiveWorkoutScreen(),
        ),
      ),
    );

    // 3. Verify the correct UI is shown
    expect(find.text('Rep Counter UI for Rep-Based Drill'), findsOneWidget);
    expect(find.text('Timer UI for Rep-Based Drill'), findsNothing);
  });
}
