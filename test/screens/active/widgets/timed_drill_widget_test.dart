import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

class MockWorkoutState extends Mock implements WorkoutState {}

void main() {
  late MockWorkoutState mockWorkoutState;

  setUp(() {
    mockWorkoutState = MockWorkoutState();
  });

  testWidgets('TimedDrillWidget shows initial time and counts down',
      (WidgetTester tester) async {
    final drill = Drill(
      drillId: 'test',
      name: 'Test Drill',
      description: 'A test drill',
      type: 'TIMED',
      config: {'duration': 5},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: mockWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: TimedDrillWidget(drill: drill),
          ),
        ),
      ),
    );

    // Check for initial state
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Test Drill'), findsOneWidget);

    // Advance the timer by 1 second
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);

    // Advance the timer by another 3 seconds
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('nextDrill is called when timer finishes',
      (WidgetTester tester) async {
    final drill = Drill(
      drillId: 'test',
      name: 'Test Drill',
      description: 'A test drill',
      type: 'TIMED',
      config: {'duration': 2},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: mockWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: TimedDrillWidget(drill: drill),
          ),
        ),
      ),
    );

    // Check initial time
    expect(find.text('2'), findsOneWidget);

    // Elapse the timer completely
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0'), findsOneWidget);

    // This pump will trigger the timer's else block
    await tester.pump(const Duration(seconds: 1));

    // Pump one more frame for the state update to propagate
    await tester.pump();

    // Verify that nextDrill was called
    verify(mockWorkoutState.nextDrill()).called(1);
  });

  testWidgets('Timer resets when drill changes', (WidgetTester tester) async {
    final drill1 = Drill(
      drillId: 'drill1',
      name: 'First Drill',
      description: '',
      type: 'TIMED',
      config: {'duration': 10},
    );
    final drill2 = Drill(
      drillId: 'drill2',
      name: 'Second Drill',
      description: '',
      type: 'TIMED',
      config: {'duration': 20},
    );

    // A helper widget to simulate the parent rebuilding with a new drill
    Widget buildWidget(Drill drill) {
      return ChangeNotifierProvider<WorkoutState>.value(
        value: mockWorkoutState,
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
    await tester.pumpWidget(buildWidget(drill1));
    expect(find.text('10'), findsOneWidget);

    // Advance time a bit
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('8'), findsOneWidget);

    // Now, rebuild with the second drill
    await tester.pumpWidget(buildWidget(drill2));

    // The timer should have reset to the new duration
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Second Drill'), findsOneWidget);

    // Advance time again to make sure the new timer is running
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('19'), findsOneWidget);
  });
}
