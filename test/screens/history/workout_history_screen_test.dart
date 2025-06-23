import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/screens/history/workout_history_screen.dart';
import 'package:flutter_bball_app/screens/summary/workout_summary_screen.dart';
import 'package:flutter_bball_app/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../mocks/mock_storage_service.dart';

void main() {
  late FakeStorageService fakeStorageService;

  setUp(() {
    fakeStorageService = FakeStorageService();
    StorageService.setInstance(fakeStorageService);
  });

  testWidgets('WorkoutHistoryScreen displays sessions and navigates',
      (WidgetTester tester) async {
    final blueprint = WorkoutBlueprint(
      id: 'bp1',
      name: 'Test Workout',
      objective: 'Test Objective',
      estimatedDuration: 10,
      drills: [],
    );
    final sessions = [
      WorkoutSession(
        id: 's1',
        workoutBlueprint: blueprint,
        results: [],
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WorkoutSession(
        id: 's2',
        workoutBlueprint: blueprint,
        results: [],
        completedAt: DateTime.now(),
      ),
    ];
    fakeStorageService.sessionsToReturn = sessions;

    await tester.pumpWidget(
      const MaterialApp(
        home: WorkoutHistoryScreen(),
      ),
    );

    await tester.pumpAndSettle(); // Wait for the FutureBuilder

    // Verify that the sessions are displayed
    expect(find.text('Test Workout'), findsNWidgets(2));

    // Tap on the first session (most recent)
    await tester.tap(find.text('Test Workout').first);
    await tester.pumpAndSettle();

    // Verify that we navigated to the summary screen
    expect(find.byType(WorkoutSummaryScreen), findsOneWidget);
    expect(find.text('Workout Complete!'), findsOneWidget);
  });
}
