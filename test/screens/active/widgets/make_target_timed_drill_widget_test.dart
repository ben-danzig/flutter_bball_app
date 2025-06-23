import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/widgets/make_target_timed_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../../mocks/mock_workout_state.dart';

void main() {
  late FakeWorkoutState fakeWorkoutState;

  setUp(() {
    fakeWorkoutState = FakeWorkoutState();
  });

  testWidgets('MakeTargetTimedDrillWidget works correctly', (WidgetTester tester) async {
    final drill = Drill(
      drillId: 'make_target_drill',
      name: 'Test Make Target Drill',
      description: '',
      type: 'MAKE_TARGET_TIMED',
      config: {'targetMakes': 2},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: fakeWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: MakeTargetTimedDrillWidget(drill: drill),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('00:00'), findsOneWidget);
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == '0 / 2',
        ),
        findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '+1 MAKE'), findsOneWidget);

    // Advance timer
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);

    // Add a make
    await tester.tap(find.widgetWithText(ElevatedButton, '+1 MAKE'));
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == '1 / 2',
        ),
        findsOneWidget);

    // Advance timer again
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:02'), findsOneWidget);

    // Add final make to complete the drill
    await tester.tap(find.widgetWithText(ElevatedButton, '+1 MAKE'));
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == '2 / 2',
        ),
        findsOneWidget);

    // Verify timer has stopped
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:02'), findsOneWidget); // Should not have changed

    // Verify UI changed to "FINISH DRILL"
    expect(find.widgetWithText(ElevatedButton, '+1 MAKE'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'FINISH DRILL'), findsOneWidget);

    // Tap finish and verify state is advanced
    await tester.tap(find.widgetWithText(ElevatedButton, 'FINISH DRILL'));
    await tester.pump();
    expect(fakeWorkoutState.nextDrillCallCount, 1);
  });

  testWidgets('log all button works correctly', (WidgetTester tester) async {
    final drill = Drill(
      drillId: 'make_target_drill',
      name: 'Test Make Target Drill',
      description: '',
      type: 'MAKE_TARGET_TIMED',
      config: {'targetMakes': 5},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: fakeWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: MakeTargetTimedDrillWidget(drill: drill),
          ),
        ),
      ),
    );

    // Tap the "LOG ALL" button
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOG ALL'));
    await tester.pump();

    // Verify the makes are updated and the drill is complete
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == '5 / 5',
        ),
        findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'FINISH DRILL'), findsOneWidget);
  });
}
