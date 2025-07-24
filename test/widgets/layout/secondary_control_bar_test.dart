import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/widgets/layout/secondary_control_bar.dart';

void main() {
  group('SecondaryControlBar', () {
    late bool pauseCalled;
    late bool previousDrillCalled;
    late bool nextDrillCalled;
    late bool endWorkoutCalled;
    late bool resetCurrentDrillCalled;

    setUp(() {
      pauseCalled = false;
      previousDrillCalled = false;
      nextDrillCalled = false;
      endWorkoutCalled = false;
      resetCurrentDrillCalled = false;
    });

    testWidgets('should render all control buttons with proper layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      // Should have proper container structure
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsOneWidget);

      // Should find all control elements
      expect(find.text('< PREV'), findsOneWidget);
      expect(find.text('|| PAUSE'), findsOneWidget);
      expect(find.text('END'), findsOneWidget);
      expect(find.text('SKIP >'), findsOneWidget);
    });

    testWidgets('should show RESUME when paused', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: true,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('RESUME'), findsOneWidget);
      expect(find.text('|| PAUSE'), findsNothing);
    });

    testWidgets('should handle previous drill tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('< PREV'));
      expect(previousDrillCalled, isTrue);
      expect(resetCurrentDrillCalled, isFalse);
    });

    testWidgets('should handle previous drill long press for reset', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.text('< PREV'));
      expect(resetCurrentDrillCalled, isTrue);
      expect(previousDrillCalled, isFalse);
    });

    testWidgets('should handle pause/resume toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('|| PAUSE'));
      expect(pauseCalled, isTrue);
    });

    testWidgets('should handle end workout button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('END'));
      expect(endWorkoutCalled, isTrue);
    });

    testWidgets('should handle skip/next drill button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('SKIP >'));
      expect(nextDrillCalled, isTrue);
    });

    testWidgets('should have proper button styling and colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      // Check PREV button styling
      final prevText = tester.widget<Text>(find.text('< PREV'));
      expect(prevText.style?.color, const Color(0xFF9ca3af));
      expect(prevText.style?.fontSize, 16);
      expect(prevText.style?.fontWeight, FontWeight.bold);

      // Check END button styling (should be red/error color)
      final endButton = tester.widget<TextButton>(
        find.byWidgetPredicate((widget) => 
          widget is TextButton && 
          (widget.child as Text?)?.data == 'END'
        ),
      );
      final endText = endButton.child as Text;
      expect(endText.style?.color, const Color(0xFFef4444));

      // Check SKIP button styling
      final skipText = tester.widget<Text>(find.text('SKIP >'));
      expect(skipText.style?.color, const Color(0xFF9ca3af));
    });

    testWidgets('should have minimum touch targets for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      // Check that buttons have adequate touch targets (minimum 44px)
      final prevGesture = tester.getSize(find.byWidgetPredicate((widget) => 
        widget is GestureDetector && 
        widget.child is Container &&
        ((widget.child as Container).child as Text?)?.data == '< PREV'
      ));
      expect(prevGesture.height, greaterThanOrEqualTo(44));

      // Check pause button
      final pauseButton = tester.getSize(find.byType(TextButton).first);
      expect(pauseButton.height, greaterThanOrEqualTo(44));
    });

    testWidgets('should have proper container padding and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 20, vertical: 10));
      
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    });

    testWidgets('should handle null callbacks gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () {},
              onPreviousDrill: () {},
              onNextDrill: () {},
              onEndWorkout: () {},
              onResetCurrentDrill: () {},
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.text('< PREV'), findsOneWidget);
      expect(find.text('|| PAUSE'), findsOneWidget);
      expect(find.text('END'), findsOneWidget);
      expect(find.text('SKIP >'), findsOneWidget);
    });

    testWidgets('should show tooltip for PREV button explaining long press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryControlBar(
              isPaused: false,
              onTogglePause: () => pauseCalled = true,
              onPreviousDrill: () => previousDrillCalled = true,
              onNextDrill: () => nextDrillCalled = true,
              onEndWorkout: () => endWorkoutCalled = true,
              onResetCurrentDrill: () => resetCurrentDrillCalled = true,
            ),
          ),
        ),
      );

      // Should have tooltip explaining the long press functionality
      expect(find.byType(Tooltip), findsOneWidget);
      
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Long press to reset drill');
    });

    group('PauseResumeButton Integration', () {
      testWidgets('should integrate with existing PauseResumeButton widget', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecondaryControlBar(
                isPaused: false,
                onTogglePause: () => pauseCalled = true,
                onPreviousDrill: () => previousDrillCalled = true,
                onNextDrill: () => nextDrillCalled = true,
                onEndWorkout: () => endWorkoutCalled = true,
                onResetCurrentDrill: () => resetCurrentDrillCalled = true,
              ),
            ),
          ),
        );

        // Should use the existing PauseResumeButton widget
        expect(find.byWidgetPredicate((widget) => 
          widget.runtimeType.toString().contains('PauseResumeButton')
        ), findsOneWidget);
      });
    });
  });
} 