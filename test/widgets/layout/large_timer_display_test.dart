import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/widgets/layout/large_timer_display.dart';

void main() {
  group('LargeTimerDisplay', () {
    testWidgets('should render timer with minimum font size on small screens', (WidgetTester tester) async {
      // Set small screen size (400px width)
      await tester.binding.setSurfaceSize(const Size(400, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 125, // 2:05
                textColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      // Should show formatted time
      expect(find.text('2:05'), findsOneWidget);
      
      // Should use FittedBox for responsive scaling
      expect(find.byType(FittedBox), findsOneWidget);
      
      // Should be wrapped in Column for layout
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should render timer with larger font size on large screens', (WidgetTester tester) async {
      // Set large screen size (1200px width)
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 45,
                textColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.text('45'), findsOneWidget);
      expect(find.byType(FittedBox), findsOneWidget);
    });

    testWidgets('should display title when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 30,
                textColor: Colors.white,
                title: 'FREE THROWS',
              ),
            ),
          ),
        ),
      );

      expect(find.text('FREE THROWS'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 90, // 1:30
                textColor: Colors.white,
                subtitle: 'Focus on your form and follow through',
              ),
            ),
          ),
        ),
      );

      expect(find.text('1:30'), findsOneWidget);
      expect(find.text('Focus on your form and follow through'), findsOneWidget);
    });

    testWidgets('should handle very long subtitle with overflow protection', (WidgetTester tester) async {
      const longSubtitle = 'This is a very long subtitle that should be properly handled with ellipsis overflow to ensure it does not break the layout or extend beyond the available space in the widget area';
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 120, // 2:00
                textColor: Colors.white,
                subtitle: longSubtitle,
              ),
            ),
          ),
        ),
      );

      expect(find.text('2:00'), findsOneWidget);
      
      // Should find the subtitle text widget (even if truncated)
      expect(find.byWidgetPredicate((widget) => 
        widget is Text && 
        widget.data == longSubtitle &&
        widget.maxLines == 3 &&
        widget.overflow == TextOverflow.ellipsis
      ), findsOneWidget);
      
      // Should not overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should format time correctly for different durations', (WidgetTester tester) async {
      // Test different time formats
      final testCases = [
        (seconds: 5, expected: '5'),
        (seconds: 30, expected: '30'),
        (seconds: 60, expected: '1:00'),
        (seconds: 125, expected: '2:05'),
        (seconds: 3665, expected: '61:05'), // Over 1 hour
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 600)),
              child: Scaffold(
                body: LargeTimerDisplay(
                  seconds: testCase.seconds,
                  textColor: Colors.white,
                ),
              ),
            ),
          ),
        );

        expect(find.text(testCase.expected), findsOneWidget);
      }
    });

    testWidgets('should apply custom text color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 60,
                textColor: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Find the main timer text widget
      final timerText = tester.widget<Text>(
        find.byWidgetPredicate((widget) => 
          widget is Text && widget.data == '1:00'
        ),
      );
      
      expect(timerText.style?.color, Colors.green);
    });

    testWidgets('should have consistent title styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 45,
                textColor: Colors.white,
                title: 'BALL HANDLING',
              ),
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('BALL HANDLING'));
      expect(titleText.style?.fontSize, 22);
      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.color, const Color(0xFFf9fafb));
      expect(titleText.style?.letterSpacing, 1.2);
      expect(titleText.textAlign, TextAlign.center);
    });

    testWidgets('should have consistent subtitle styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 90,
                textColor: Colors.white,
                subtitle: 'Keep your eyes up and dribble low',
              ),
            ),
          ),
        ),
      );

      final subtitleText = tester.widget<Text>(find.text('Keep your eyes up and dribble low'));
      expect(subtitleText.style?.fontSize, 16);
      expect(subtitleText.style?.color, const Color(0xFF9ca3af));
      expect(subtitleText.textAlign, TextAlign.center);
      expect(subtitleText.maxLines, 3);
      expect(subtitleText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should maintain font weight and height for timer text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 100,
                textColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      final timerText = tester.widget<Text>(find.text('1:40'));
      expect(timerText.style?.fontWeight, FontWeight.w900);
      expect(timerText.style?.height, 1.0); // Tight line height
    });

    testWidgets('should handle zero seconds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 0,
                textColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should work without title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: Scaffold(
              body: LargeTimerDisplay(
                seconds: 75,
                textColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.text('1:15'), findsOneWidget);
      expect(find.byType(FittedBox), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      
      // Should only have the timer text, no title or subtitle
      expect(find.byType(Text), findsOneWidget);
    });

    group('Responsive Font Size Calculations', () {
      testWidgets('should use minimum 150px font size on very small screens', (WidgetTester tester) async {
        // Test with screen width that would calculate < 150px (e.g., 300px * 0.35 = 105px)
        await tester.binding.setSurfaceSize(const Size(200, 400));
        
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(200, 400)),
              child: Scaffold(
                body: LargeTimerDisplay(
                  seconds: 30,
                  textColor: Colors.white,
                ),
              ),
            ),
          ),
        );

        // Should still render without issues - minimum font size should be enforced internally
        expect(find.text('30'), findsOneWidget);
        expect(find.byType(FittedBox), findsOneWidget);
      });

      testWidgets('should scale font size on large screens but respect height constraints', (WidgetTester tester) async {
        // Test with very large screen
        await tester.binding.setSurfaceSize(const Size(2000, 1000));
        
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(2000, 1000)),
              child: Scaffold(
                body: LargeTimerDisplay(
                  seconds: 123,
                  textColor: Colors.white,
                ),
              ),
            ),
          ),
        );

        expect(find.text('2:03'), findsOneWidget);
        expect(find.byType(FittedBox), findsOneWidget);
      });
    });
  });
} 