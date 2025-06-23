import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/active/active_workout_screen.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  // Helper function to create a mock blueprint with a single drill of a given type
  WorkoutBlueprint createMockBlueprint(String drillType) {
    return WorkoutBlueprint(
      id: 'mock_id',
      name: 'Mock Workout',
      objective: '',
      estimatedDuration: 1,
      drills: [
        Drill(drillId: 'd1', name: 'Mock Drill', description: '', type: drillType, config: {})
      ],
    );
  }

  // Helper function to wrap our screen in the necessary providers for testing
  Widget createTestableScreen(WorkoutState state) {
    return ChangeNotifierProvider.value(
      value: state,
      child: const MaterialApp(home: ActiveWorkoutScreen()),
    );
  }

  testWidgets('displays TimedDrillView for TIMED drill type', (WidgetTester tester) async {
    // ARRANGE
    final workoutState = WorkoutState();
    final blueprint = createMockBlueprint('TIMED');
    workoutState.startWorkout(blueprint);

    // ACT
    await tester.pumpWidget(createTestableScreen(workoutState));

    // ASSERT
    expect(find.textContaining('Placeholder for TIMED drill'), findsOneWidget);
    expect(find.textContaining('REP_BASED'), findsNothing);
  });

  testWidgets('displays RepBasedDrillView for REP_BASED drill type', (WidgetTester tester) async {
    // ARRANGE
    final workoutState = WorkoutState();
    final blueprint = createMockBlueprint('REP_BASED');
    workoutState.startWorkout(blueprint);

    // ACT
    await tester.pumpWidget(createTestableScreen(workoutState));

    // ASSERT
    expect(find.textContaining('Placeholder for REP_BASED drill'), findsOneWidget);
    expect(find.textContaining('TIMED'), findsNothing);
  });
}