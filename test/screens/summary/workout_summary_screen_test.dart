import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/drill_result.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/screens/summary/workout_summary_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WorkoutSummaryScreen displays all session information',
      (WidgetTester tester) async {
    final blueprint = WorkoutBlueprint(
      id: 'bp1',
      name: 'Test Workout',
      objective: 'Test Objective',
      estimatedDuration: 10,
      drills: [
        Drill(drillId: 'd1', name: 'Timed Drill', description: '', type: 'TIMED', config: {'duration': 60}),
        Drill(drillId: 'd2', name: 'Rep Drill', description: '', type: 'REP_BASED', config: {'targetMakes': 10}),
      ],
    );

    final session = WorkoutSession(
      id: 's1',
      workoutBlueprint: blueprint,
      results: [
        DrillResult(drillId: 'd1', elapsedSeconds: 55),
        DrillResult(drillId: 'd2', makes: 8),
      ],
      completedAt: DateTime.now(),
      feeling: '😌 Feeling Great',
      notes: 'Good session today.',
      deviceId: 'testDevice'
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutSummaryScreen(session: session),
      ),
    );

    // Verify header
    expect(find.text('Workout Complete!'), findsOneWidget);

    // Verify summary card
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Test Workout'), findsOneWidget);
    expect(find.text('Total Time'), findsOneWidget);
    expect(find.text('0m 55s'), findsOneWidget);

    // Verify results card
    expect(find.text('RESULTS'), findsOneWidget);
    expect(find.text('Timed Drill'), findsOneWidget);
    expect(find.text('55s'), findsOneWidget);
    expect(find.text('Rep Drill'), findsOneWidget);
    expect(find.text('8 / 10'), findsOneWidget);

    // Verify feeling card
    expect(find.text('Feeling'), findsOneWidget);
    expect(find.text('😌 Feeling Great'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Good session today.'), findsOneWidget);
  });
}
