import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/widgets/rep_based_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockWorkoutState extends Mock implements WorkoutState {}

void main() {
  late MockWorkoutState mockWorkoutState;

  setUp(() {
    mockWorkoutState = MockWorkoutState();
  });

  testWidgets('RepBasedDrillWidget shows modal and logs set', (WidgetTester tester) async {
    final drill = Drill(
      drillId: 'rep_drill',
      name: 'Test Rep Drill',
      description: '',
      type: 'REP_BASED',
      config: {'targetMakes': 10},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: mockWorkoutState,
        child: MaterialApp(
          home: Scaffold(
            body: RepBasedDrillWidget(drill: drill),
          ),
        ),
      ),
    );

    // Verify initial UI
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RichText &&
              widget.text.toPlainText() == '0 / 10',
        ),
        findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Tap the "LOG SET" button
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOG SET >'));
    await tester.pumpAndSettle(); // Wait for modal animation

    // Verify modal is shown
    expect(find.text('Log Your Set'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter makes into the TextField
    await tester.enterText(find.byType(TextField), '8');
    await tester.pump();

    // Tap the "Save Set" button
    await tester.tap(find.widgetWithText(ElevatedButton, 'SAVE & CONTINUE'));
    await tester.pumpAndSettle(); // Wait for modal to close

    // Verify modal is gone
    expect(find.text('Log Your Set'), findsNothing);

    // Verify that the correct method was called on the state
    // For now, we just check nextDrill. Later we'll check a specific log method.
    verify(mockWorkoutState.nextDrill()).called(1);
  });
}
