import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/utils/responsive/breakpoints.dart';

void main() {
  group('ResponsiveBreakpoints', () {
    testWidgets('should detect mobile screen dimensions correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 500));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('IsMobile: ${ResponsiveBreakpoints.isMobile(context)}'),
                    Text('IsSmallHeight: ${ResponsiveBreakpoints.isSmallHeight(context)}'),
                    Text('IsDesktop: ${ResponsiveBreakpoints.isDesktop(context)}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('IsMobile: true'), findsOneWidget);
      expect(find.text('IsSmallHeight: true'), findsOneWidget);
      expect(find.text('IsDesktop: false'), findsOneWidget);
    });

    testWidgets('should detect desktop screen dimensions correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('IsMobile: ${ResponsiveBreakpoints.isMobile(context)}'),
                    Text('IsSmallHeight: ${ResponsiveBreakpoints.isSmallHeight(context)}'),
                    Text('IsDesktop: ${ResponsiveBreakpoints.isDesktop(context)}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('IsMobile: false'), findsOneWidget);
      expect(find.text('IsSmallHeight: false'), findsOneWidget);
      expect(find.text('IsDesktop: true'), findsOneWidget);
    });

    testWidgets('should handle edge case dimensions', (WidgetTester tester) async {
      // Test exact breakpoint values
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('IsMobile: ${ResponsiveBreakpoints.isMobile(context)}'),
                    Text('IsSmallHeight: ${ResponsiveBreakpoints.isSmallHeight(context)}'),
                    Text('IsDesktop: ${ResponsiveBreakpoints.isDesktop(context)}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // At exactly 800px width and 600px height, should be considered desktop/normal
      expect(find.text('IsMobile: false'), findsOneWidget);
      expect(find.text('IsSmallHeight: false'), findsOneWidget);
      expect(find.text('IsDesktop: true'), findsOneWidget);
    });

    group('Breakpoint Constants', () {
      test('should have correct breakpoint values', () {
        expect(ResponsiveBreakpoints.mobileMaxWidth, 800);
        expect(ResponsiveBreakpoints.smallHeightThreshold, 600);
        expect(ResponsiveBreakpoints.desktopMinWidth, 801);
      });
    });

  });

  group('ResponsiveUtils', () {
    testWidgets('should provide correct padding for screen size', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 500));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getContentPadding(context);
              return Scaffold(
                body: Text('Padding: ${padding.toString()}'),
              );
            },
          ),
        ),
      );

      expect(find.text('Padding: EdgeInsets.all(10.0)'), findsOneWidget);
    });

    testWidgets('should provide correct font size scale for screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 700));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scale = ResponsiveUtils.getTimerFontScale(context);
              return Scaffold(
                body: Text('Font Scale: ${scale.toStringAsFixed(2)}'),
              );
            },
          ),
        ),
      );

      // Should be around 1.0 for normal mobile screens
      expect(find.textContaining('Font Scale: 1.0'), findsOneWidget);
    });
  });
} 