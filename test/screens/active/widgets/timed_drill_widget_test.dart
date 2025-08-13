import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/widgets/layout/split_priority_layout.dart';  
import 'package:flutter_bball_app/widgets/layout/primary_action_bar.dart';
import 'package:flutter_bball_app/widgets/layout/secondary_control_bar.dart';
import 'package:flutter_bball_app/widgets/layout/large_timer_display.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'timed_drill_widget_test.mocks.dart';

@GenerateMocks([WorkoutState])
void main() {
  group('TimedDrillWidget', () {
    late MockWorkoutState mockWorkoutState;
    late Drill testDrill;

    setUp(() {
      mockWorkoutState = MockWorkoutState();
      testDrill = Drill(
        drillId: 'test-drill',
        name: 'Test Timed Drill',
        description: 'A test drill for timing',
        type: 'TIMED',
        config: {'duration': 60}, // 60 seconds
      );

      // Setup default mock behaviors
      when(mockWorkoutState.isPaused).thenReturn(false);
      when(mockWorkoutState.currentDrillIndex).thenReturn(0);
      when(mockWorkoutState.resetDrillCounter).thenReturn(0);
    });

    Widget createTestWidget({bool isPaused = false}) {
      when(mockWorkoutState.isPaused).thenReturn(isPaused);
      
      return MaterialApp(
        home: ChangeNotifierProvider<WorkoutState>.value(
          value: mockWorkoutState,
          child: TimedDrillWidget(drill: testDrill),
        ),
      );
    }

    group('Layout Integration', () {
      testWidgets('should use SplitPriorityLayout structure', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should use SplitPriorityLayout
        expect(find.byType(SplitPriorityLayout), findsOneWidget);
        
        // Should have the three main sections
        expect(find.byType(PrimaryActionBar), findsOneWidget);
        expect(find.byType(LargeTimerDisplay), findsOneWidget);
        expect(find.byType(SecondaryControlBar), findsOneWidget);
      });

      testWidgets('should show no primary action for TIMED drill type', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final primaryActionBar = tester.widget<PrimaryActionBar>(
          find.byType(PrimaryActionBar)
        );
        
        // TIMED drills should not have primary actions
        expect(primaryActionBar.onPrimaryAction, isNull);
      });

      testWidgets('should show UP NEXT text in primary action bar', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should display "UP NEXT: [next drill name]" or "Workout Complete"
        expect(find.textContaining('UP NEXT'), findsOneWidget);
      });
    });

    group('Timer Display', () {
      testWidgets('should use LargeTimerDisplay with drill title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final timerDisplay = tester.widget<LargeTimerDisplay>(
          find.byType(LargeTimerDisplay)
        );
        
        expect(timerDisplay.title, testDrill.name.toUpperCase());
        expect(timerDisplay.subtitle, testDrill.description);
        expect(timerDisplay.seconds, 60); // Initial duration
      });

      testWidgets('should countdown from initial duration', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initially should show 1:00
        expect(find.text('1:00'), findsOneWidget);
        
        // Advance time by 1 second
        await tester.pump(const Duration(seconds: 1));
        
        // Should now show 0:59
        expect(find.text('0:59'), findsOneWidget);
      });

      testWidgets('should handle tap to edit time functionality', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap on the timer to edit
        await tester.tap(find.byType(LargeTimerDisplay));
        await tester.pumpAndSettle();

        // Should show time picker dialog
        expect(find.text('Edit Time'), findsOneWidget);
        expect(find.text('Minutes'), findsOneWidget);
        expect(find.text('Seconds'), findsOneWidget);
      });

      testWidgets('should pause timer when workout is paused', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initially should show 1:00
        expect(find.text('1:00'), findsOneWidget);
        
        // Change to paused state
        when(mockWorkoutState.isPaused).thenReturn(true);
        await tester.pumpWidget(createTestWidget(isPaused: true));
        
        // Advance time by 1 second
        await tester.pump(const Duration(seconds: 1));
        
        // Should still show 1:00 (not counting down when paused)
        expect(find.text('1:00'), findsOneWidget);
      });
    });

    group('Secondary Controls', () {
      testWidgets('should provide secondary control callbacks', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final secondaryControlBar = tester.widget<SecondaryControlBar>(
          find.byType(SecondaryControlBar)
        );
        
        // Should have all required callbacks
        expect(secondaryControlBar.onTogglePause, isNotNull);
        expect(secondaryControlBar.onPreviousDrill, isNotNull);
        expect(secondaryControlBar.onNextDrill, isNotNull);
        expect(secondaryControlBar.onEndWorkout, isNotNull);
        expect(secondaryControlBar.onResetCurrentDrill, isNotNull);
      });

      testWidgets('should call WorkoutState methods on secondary control interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap PREV button
        await tester.tap(find.text('< PREV'));
        verify(mockWorkoutState.previousDrill()).called(1);

        // Tap SKIP button  
        await tester.tap(find.text('SKIP >'));
        verify(mockWorkoutState.nextDrill()).called(1);

        // Tap PAUSE button
        await tester.tap(find.text('|| PAUSE'));
        verify(mockWorkoutState.togglePause()).called(1);
      });

      testWidgets('should handle long press on PREV for drill reset', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Long press PREV button
        await tester.longPress(find.text('< PREV'));
        verify(mockWorkoutState.resetCurrentDrill()).called(1);
      });
    });

    group('Timer Completion', () {
      testWidgets('should call logTimedDrill and nextDrill when timer completes', (WidgetTester tester) async {
        // Create drill with very short duration for testing
        final shortDrill = Drill(
          drillId: 'short-drill',
          name: 'Short Test Drill', 
          description: 'Quick test',
          type: 'TIMED',
          config: {'duration': 1}, // 1 second
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<WorkoutState>.value(
              value: mockWorkoutState,
              child: TimedDrillWidget(drill: shortDrill),
            ),
          ),
        );

        // Wait for timer to complete
        await tester.pump(const Duration(seconds: 2));

        // Should have called the completion methods
        verify(mockWorkoutState.logTimedDrill()).called(1);
        verify(mockWorkoutState.nextDrill()).called(1);
      });
    });

    group('Drill Reset Handling', () {
      testWidgets('should reset timer when resetDrillCounter changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Let timer run down a bit
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('0:55'), findsOneWidget);

        // Simulate drill reset by changing reset counter
        when(mockWorkoutState.resetDrillCounter).thenReturn(1);
        await tester.pumpWidget(createTestWidget());

        // Timer should reset to original duration
        expect(find.text('1:00'), findsOneWidget);
      });
    });

    group('Progress Indication', () {
      testWidgets('should show proper progress in SplitPriorityLayout', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final splitLayout = tester.widget<SplitPriorityLayout>(
          find.byType(SplitPriorityLayout)
        );
        
        // Should show progress indicator
        expect(splitLayout.showProgressIndicator, isTrue);
        // Progress should be calculated based on remaining time  
        expect(splitLayout.progress, greaterThanOrEqualTo(0.0));
        expect(splitLayout.progress, lessThanOrEqualTo(1.0));
      });
    });

    group('Responsive Behavior', () {
      testWidgets('should handle small screen sizes appropriately', (WidgetTester tester) async {
        // Set small screen size
        await tester.binding.setSurfaceSize(const Size(400, 600));
        
        await tester.pumpWidget(createTestWidget());

        // Should still render all components properly
        expect(find.byType(SplitPriorityLayout), findsOneWidget);
        expect(find.byType(LargeTimerDisplay), findsOneWidget);
        expect(find.byType(SecondaryControlBar), findsOneWidget);
      });

      testWidgets('should handle large screen sizes appropriately', (WidgetTester tester) async {
        // Set large screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        
        await tester.pumpWidget(createTestWidget());

        // Should still render all components properly
        expect(find.byType(SplitPriorityLayout), findsOneWidget);
        expect(find.byType(LargeTimerDisplay), findsOneWidget);
        expect(find.byType(SecondaryControlBar), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle missing drill duration gracefully', (WidgetTester tester) async {
        final invalidDrill = Drill(
          drillId: 'invalid-drill',
          name: 'Invalid Drill',
          description: 'Missing duration',
          type: 'TIMED',
          config: {}, // No duration specified
        );

        // Should not throw error but provide reasonable default
        expect(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider<WorkoutState>.value(
                value: mockWorkoutState,
                child: TimedDrillWidget(drill: invalidDrill),
              ),
            ),
          );
        }, returnsNormally);
      });
    });
  });
}
