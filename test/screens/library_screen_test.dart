import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/screens/library/workout_library_screen.dart';
import 'package:flutter_bball_app/screens/detail/workout_detail_screen.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';

void main() {
  testWidgets('WorkoutLibraryScreen displays workout card', (WidgetTester tester) async {
    // Pump the widget
    await tester.pumpWidget(const MaterialApp(
      home: WorkoutLibraryScreen(),
    ));

    // Verify the title is displayed
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Choose a workout to start your session.'), findsOneWidget);

    // Initially, we should see a loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Tapping on workout card navigates to detail screen', (WidgetTester tester) async {
    // Create a test widget that simulates the WorkoutLibraryScreen with a workout card
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

    // Create a test widget that simulates the WorkoutLibraryScreen with a workout card
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(
                      blueprint: sampleBlueprint,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleBlueprint.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF60A5FA), // Light Blue
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sampleBlueprint.objective,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${sampleBlueprint.estimatedDuration} MINS • ${sampleBlueprint.drills.length} DRILLS',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap on the workout card
    await tester.tap(find.text('Test Workout'));
    await tester.pumpAndSettle();

    // Verify we've navigated to the detail screen
    expect(find.byType(WorkoutDetailScreen), findsOneWidget);
    expect(find.text('Drills'), findsOneWidget);
    expect(find.text('Test Drill'), findsOneWidget);
  });
}
