import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/widgets/layout/responsive_content_area.dart';

void main() {
  group('ResponsiveContentArea', () {
    late Widget mockChild;

    setUp(() {
      mockChild = Container(
        key: const Key('test-child'),
        color: Colors.blue,
        child: const Text('Test Content'),
      );
    });

    testWidgets('should render child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContentArea(
              child: mockChild,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test-child')), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should apply default padding on normal screens', (WidgetTester tester) async {
      // Set normal screen size (height >= 600px)
      await tester.binding.setSurfaceSize(const Size(400, 700));
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 700)),
            child: Scaffold(
              body: ResponsiveContentArea(
                child: mockChild,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.padding, const EdgeInsets.all(20));
    });

    testWidgets('should apply reduced padding on small screens', (WidgetTester tester) async {
      // Set small screen size (height < 600px)
      await tester.binding.setSurfaceSize(const Size(400, 500));
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 500)),
            child: Scaffold(
              body: ResponsiveContentArea(
                child: mockChild,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.padding, const EdgeInsets.all(10));
    });

    testWidgets('should use custom padding when provided', (WidgetTester tester) async {
      const customPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContentArea(
              padding: customPadding,
              child: mockChild,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.padding, customPadding);
    });

    testWidgets('should set full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContentArea(
              child: mockChild,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.minWidth, double.infinity);
    });

    group('Screen Size Breakpoints', () {
      testWidgets('should detect screen height exactly at 600px as normal', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResponsiveContentArea(
                child: mockChild,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.padding, const EdgeInsets.all(20));
      });

      testWidgets('should detect screen height of 599px as small', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 599));
        
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 599)),
              child: Scaffold(
                body: ResponsiveContentArea(
                  child: mockChild,
                ),
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.padding, const EdgeInsets.all(10));
      });

      testWidgets('should handle very small screens gracefully', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(200, 300));
        
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(200, 300)),
              child: Scaffold(
                body: ResponsiveContentArea(
                  child: mockChild,
                ),
              ),
            ),
          ),
        );

        // Should still render without issues
        expect(find.byKey(const Key('test-child')), findsOneWidget);
        
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.padding, const EdgeInsets.all(10));
      });

      testWidgets('should handle large screens correctly', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1000));
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResponsiveContentArea(
                child: mockChild,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.padding, const EdgeInsets.all(20));
      });
    });


  });
} 