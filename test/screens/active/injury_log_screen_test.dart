import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/screens/active/injury_log_screen.dart';
import 'package:flutter_bball_app/services/storage_service.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../mocks/mock_storage_service.dart';
import '../../mocks/mock_workout_state.dart';

void main() {
  late FakeWorkoutState fakeWorkoutState;
  late FakeStorageService fakeStorageService;

  setUp(() {
    fakeWorkoutState = FakeWorkoutState();
    fakeStorageService = FakeStorageService();
    StorageService.setInstance(fakeStorageService); // Inject the fake

    final blueprint = WorkoutBlueprint(
      id: 'test_id',
      name: 'Test Workout',
      objective: 'Test objective',
      estimatedDuration: 10,
      drills: [],
    );
    fakeWorkoutState.startWorkout(blueprint);
  });

  testWidgets('InjuryLogScreen saves workout and navigates',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkoutState>.value(
        value: fakeWorkoutState,
        child: const MaterialApp(
          home: InjuryLogScreen(),
        ),
      ),
    );

    // Select a feeling
    await tester.tap(find.text('🤕 Minor Soreness'));
    await tester.pump();

    // Enter notes
    await tester.enterText(find.byType(TextField), 'Knee is a bit sore.');
    await tester.pump();

    // Tap the save button
    await tester.tap(find.text('FINISH & SAVE WORKOUT'));
    await tester.pumpAndSettle();

    // Verify that saveSession was called
    expect(fakeStorageService.lastSavedSession, isNotNull);
    expect(fakeStorageService.lastSavedSession?.feeling, '🤕 Minor Soreness');
    expect(fakeStorageService.lastSavedSession?.notes, 'Knee is a bit sore.');

    // Verify that the workout was ended
    expect(fakeWorkoutState.isWorkoutStarted, isFalse);
  });
}
