import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/screens/history/workout_history_screen.dart';
import 'package:flutter_bball_app/screens/summary/workout_summary_screen.dart';
import 'package:flutter_bball_app/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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

  testWidgets('WorkoutHistoryScreen shows popup menu for each workout',
      (WidgetTester tester) async {
    final blueprint = WorkoutBlueprint(
      id: 'bp1',
      name: 'Test Workout',
      objective: 'Test Objective',
      estimatedDuration: 10,
      drills: [],
    );
    final session = WorkoutSession(
      id: 's1',
      workoutBlueprint: blueprint,
      results: [],
      completedAt: DateTime.now(),
    );
    fakeStorageService.sessionsToReturn = [session];

    await tester.pumpWidget(
      const MaterialApp(
        home: WorkoutHistoryScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the popup menu button
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify popup menu items
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Edit workout updates session with new notes and feeling',
      (WidgetTester tester) async {
    final blueprint = WorkoutBlueprint(
      id: 'bp1',
      name: 'Test Workout',
      objective: 'Test Objective',
      estimatedDuration: 10,
      drills: [],
    );
    final session = WorkoutSession(
      id: 's1',
      workoutBlueprint: blueprint,
      results: [],
      completedAt: DateTime.now(),
      feeling: 'Good',
      notes: 'Initial notes',
    );
    fakeStorageService.sessionsToReturn = [session];

    await tester.pumpWidget(
      const MaterialApp(
        home: WorkoutHistoryScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Open popup menu and tap Edit
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Verify edit dialog appears
    expect(find.text('Edit Workout'), findsOneWidget);
    expect(find.text('How did you feel?'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);

    // Update feeling and notes
    await tester.enterText(find.widgetWithText(TextField, 'How did you feel?'), 'Great');
    await tester.enterText(find.widgetWithText(TextField, 'Notes'), 'Updated notes');

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify update was called
    expect(fakeStorageService.updateSessionCalled, isTrue);
    expect(fakeStorageService.lastUpdatedSession?.feeling, 'Great');
    expect(fakeStorageService.lastUpdatedSession?.notes, 'Updated notes');
  });

  testWidgets('Delete workout shows confirmation and removes session',
      (WidgetTester tester) async {
    final blueprint = WorkoutBlueprint(
      id: 'bp1',
      name: 'Test Workout',
      objective: 'Test Objective',
      estimatedDuration: 10,
      drills: [],
    );
    final completedAt = DateTime.now();
    final session = WorkoutSession(
      id: 's1',
      workoutBlueprint: blueprint,
      results: [],
      completedAt: completedAt,
    );
    fakeStorageService.sessionsToReturn = [session];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WorkoutHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Open popup menu and tap Delete
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify delete confirmation dialog
    expect(find.text('Delete Workout'), findsOneWidget);
    final expectedText = 'Are you sure you want to delete "Test Workout" from ${DateFormat.yMMMMd().format(completedAt)}?';
    expect(find.text(expectedText), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    // Verify delete was called
    expect(fakeStorageService.deleteSessionCalled, isTrue);
    expect(fakeStorageService.lastDeletedSessionId, 's1');
  });
}
