import 'package:flutter/material.dart';
import 'package:flutter_bball_app/screens/library/workout_library_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // This is necessary for asset loading in tests
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WorkoutLibraryScreen loads and displays a workout card', (WidgetTester tester) async {
    // 1. ARRANGE: Pump our main screen widget.
    await tester.pumpWidget(const MaterialApp(home: WorkoutLibraryScreen()));

    // The first frame shows a loading indicator while the Future is resolving.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 2. ACT: Re-render the widget after the Future has completed.
    await tester.pumpAndSettle();

    // 3. ASSERT: Verify the loading indicator is gone and our card data is displayed.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Foundational Ball Control & Finishing'), findsOneWidget);
    expect(find.text('Develop adaptable dribble control and master finishing through contact and in chaotic situations.'), findsOneWidget);
  });
}