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
    Map<String, int> config;
    switch (drillType) {
      case 'TIMED':
        config = {'duration': 10};
        break;
      case 'REP_BASED':
        config = {'targetMakes': 5};
        break;
      case 'MAKE_TARGET_TIMED':
        config = {'targetMakes': 10};
        break;
      default:
        config = {};
    }

    return WorkoutBlueprint(
      id: 'mock_id',
      name: 'Mock Workout',
      objective: '',
      estimatedDuration: 1,
      drills: [
        Drill(
            drillId: 'd1',
            name: 'Mock Drill',
            description: '',
            type: drillType,
            config: config)
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
    // We no longer have a placeholder, we have the real widget.
    // Let's check for the drill name and the initial time.
    expect(find.text('Mock Drill'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
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
