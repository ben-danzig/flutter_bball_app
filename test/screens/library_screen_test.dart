import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/screens/library/workout_library_screen.dart';

void main() {
  testWidgets('WorkoutLibraryScreen displays loading indicator and then content',
      (WidgetTester tester) async {
    // For now, since the repository is hardcoded to load from assets,
    // this test will actually load the real data.
    // In a more complex app, we would mock the WorkoutRepository.

    // Pump the WorkoutLibraryScreen widget.
    await tester.pumpWidget(const MaterialApp(home: WorkoutLibraryScreen()));

    // At first, a loading indicator should be visible.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Foundational Ball Control & Finishing'), findsNothing);

    // Re-render the widget after the future has completed.
    await tester.pumpAndSettle();

    // Now, the loading indicator should be gone, and the workout card should be visible.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Foundational Ball Control & Finishing'), findsOneWidget);
    expect(
        find.text(
            'Develop adaptable dribble control and master finishing through contact and in chaotic situations.'),
        findsOneWidget);
    expect(find.text('25 MINS • 5 DRILLS'), findsOneWidget);
  });
}
