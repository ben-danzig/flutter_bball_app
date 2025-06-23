import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/active/active_workout_screen.dart';
import 'package:flutter_bball_app/screens/active/widgets/active_drill_layout.dart';
import 'package:flutter_bball_app/screens/active/widgets/rep_based_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
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

  testWidgets('displays correct layout and drill widget for TIMED drill',
      (WidgetTester tester) async {
    // ARRANGE
    final workoutState = WorkoutState();
    final blueprint = createMockBlueprint('TIMED');
    workoutState.startWorkout(blueprint);

    // ACT
    await tester.pumpWidget(createTestableScreen(workoutState));

    // ASSERT
    // Check for layout elements
    expect(find.byType(ActiveDrillLayout), findsOneWidget);
    expect(find.text('UP NEXT: Workout Complete'), findsOneWidget); // Only one drill in mock
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Check for the specific drill widget content
    expect(find.byType(TimedDrillWidget), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);
  });

  testWidgets('displays correct layout and drill widget for REP_BASED drill',
      (WidgetTester tester) async {
    // ARRANGE
    final workoutState = WorkoutState();
    final blueprint = createMockBlueprint('REP_BASED');
    workoutState.startWorkout(blueprint);

    // ACT
    await tester.pumpWidget(createTestableScreen(workoutState));

    // ASSERT
    // Check for layout elements
    expect(find.byType(ActiveDrillLayout), findsOneWidget);

    // Check for the specific drill widget content
    expect(find.byType(RepBasedDrillWidget), findsOneWidget);
    // Check for the RichText widget that contains the makes
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == '0 / 5',
        ),
        findsOneWidget);
  });
}
