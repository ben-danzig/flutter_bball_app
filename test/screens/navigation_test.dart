import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/detail/workout_detail_screen.dart';

void main() {
  testWidgets('Navigation to detail screen works correctly',
      (WidgetTester tester) async {
    // Create a sample workout blueprint
    final sampleBlueprint = WorkoutBlueprint(
      id: 'test-id',
      name: 'Test Workout',
      objective: 'Test objective',
      estimatedDuration: 30,
      drills: [
        Drill(
          drillId: 'drill-1',
          name: 'Test Drill',
          description: 'Test description',
          type: 'TIMED',
          config: {'duration': 60, 'sets': 3},
        ),
      ],
    );

    // Flag to track if navigation occurred
    bool navigated = false;

    // Create a test widget that has a button to navigate to the detail screen
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                navigated = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(
                      workout: sampleBlueprint,
                    ),
                  ),
                );
              },
              child: const Text('Go to Detail'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to navigate
    await tester.tap(find.text('Go to Detail'));
    await tester.pumpAndSettle();

    // Verify navigation occurred
    expect(navigated, true);

    // Verify we're on the detail screen
    expect(find.byType(WorkoutDetailScreen), findsOneWidget);
    expect(find.text('Test Workout'), findsOneWidget); // Title appears in app bar
    expect(find.text('TEST WORKOUT'), findsOneWidget); // Title appears in body
    expect(find.text('Test objective'), findsOneWidget);
    // The word "Drills:" is no longer in the UI, it's just a list of drills.
    expect(find.text('Test Drill'), findsOneWidget);
  });
}
