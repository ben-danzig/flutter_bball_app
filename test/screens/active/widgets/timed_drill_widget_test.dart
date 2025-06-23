import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../../mocks/mock_workout_state.dart';

void main() {
  late FakeWorkoutState fakeWorkoutState;

  setUp(() {
    fakeWorkoutState = FakeWorkoutState();
    final blueprint = WorkoutBlueprint(
      id: 'test_id',
      name: 'Test Workout',
      objective: 'Test objective',
      estimatedDuration: 10,
      drills: [
        Drill(drillId: 'd1', name: 'Drill 1', description: 'A test drill', type: 'TIMED', config: {'duration': 5}),
        Drill(drillId: 'd2', name: 'Drill 2', description: 'A test drill', type: 'TIMED', config: {'duration': 2}),
        Drill(drillId: 'd3', name: 'Drill 3', description: '', type: 'TIMED', config: {'duration': 10}),
        Drill(drillId: 'd4', name: 'Drill 4', description: '', type: 'TIMED', config: {'duration': 20}),
      ],
    );
    fakeWorkoutState.startWorkout(blueprint);
  });

  testWidgets('TimedDrillWidget shows initial time and counts down',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: fakeWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: TimedDrillWidget(drill: fakeWorkoutState.currentDrill!),
          ),
        ),
      ),
    );

    // Check for initial state
    expect(find.text('00:05'), findsOneWidget);

    // Advance the timer by 1 second
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:04'), findsOneWidget);

    // Advance the timer by another 3 seconds
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:01'), findsOneWidget);
  });

  // testWidgets('nextDrill is called when timer finishes',
  //     (WidgetTester tester) async {
  //   fakeWorkoutState.nextDrill(); // Move to the second drill
  //   await tester.pumpWidget(
  //     ChangeNotifierProvider<WorkoutState>.value(
  //       value: fakeWorkoutState,
  //       child: MaterialApp(
  //         home: Scaffold(
  //           body: TimedDrillWidget(drill: fakeWorkoutState.currentDrill!),
  //         ),
  //       ),
  //     ),
  //   );

  //   // Check initial time
  //   expect(find.text('00:02'), findsOneWidget);

  //   // Elapse the timer completely
  //   await tester.pump(const Duration(seconds: 1));
  //   expect(find.text('00:01'), findsOneWidget);
  //   await tester.pump(const Duration(seconds: 1));
  //   expect(find.text('00:00'), findsOneWidget);

  //   // This pump will trigger the timer's else block
  //   await tester.pump(const Duration(seconds: 1));

  //   // Pump one more frame for the state update to propagate
  //   await tester.pump();

  //   // Verify that nextDrill was called
  //   expect(fakeWorkoutState.nextDrillCallCount, 1);
  //   expect(fakeWorkoutState.lastLoggedResult?.drillId, 'd2');
  //   expect(fakeWorkoutState.lastLoggedResult?.elapsedSeconds, 2);
  // });

  testWidgets('Timer resets when drill changes', (WidgetTester tester) async {
    // A helper widget to simulate the parent rebuilding with a new drill
    Widget buildWidget(Drill drill) {
      return ChangeNotifierProvider<WorkoutState>.value(
        value: fakeWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: TimedDrillWidget(
              key: ValueKey(drill.drillId),
              drill: drill,
            ),
          ),
        ),
      );
    }

    // Pump the first drill
    fakeWorkoutState.nextDrill(); // d2
    fakeWorkoutState.nextDrill(); // d3
    await tester.pumpWidget(buildWidget(fakeWorkoutState.currentDrill!));
    expect(find.text('00:10'), findsOneWidget);

    // Advance time a bit
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:08'), findsOneWidget);

    // Now, rebuild with the second drill
    fakeWorkoutState.nextDrill(); // d4
    await tester.pumpWidget(buildWidget(fakeWorkoutState.currentDrill!));

    // The timer should have reset to the new duration
    expect(find.text('00:20'), findsOneWidget);

    // Advance time again to make sure the new timer is running
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:19'), findsOneWidget);
  });
}
