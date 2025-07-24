import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/widgets/layout/split_priority_layout.dart';

void main() {
  group('SplitPriorityLayout', () {
    late Widget mockPrimaryActionBar;
    late Widget mockContent;
    late Widget mockSecondaryControlBar;

    setUp(() {
      mockPrimaryActionBar = Container(
        key: const Key('primary-action-bar'),
        height: 50,
        color: Colors.blue,
        child: const Text('Primary Actions'),
      );
      
      mockContent = Container(
        key: const Key('content-area'),
        color: Colors.green,
        child: const Text('Content Area'),
      );
      
      mockSecondaryControlBar = Container(
        key: const Key('secondary-control-bar'),
        height: 50,
        color: Colors.red,
        child: const Text('Secondary Controls'),
      );
    });

    testWidgets('should render three sections with correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitPriorityLayout(
            primaryActionBar: mockPrimaryActionBar,
            content: mockContent,
            secondaryControlBar: mockSecondaryControlBar,
          ),
        ),
      );

      // Verify all three sections are present
      expect(find.byKey(const Key('primary-action-bar')), findsOneWidget);
      expect(find.byKey(const Key('content-area')), findsOneWidget);
      expect(find.byKey(const Key('secondary-control-bar')), findsOneWidget);

      // Verify layout structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('should apply correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitPriorityLayout(
            primaryActionBar: mockPrimaryActionBar,
            content: mockContent,
            secondaryControlBar: mockSecondaryControlBar,
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF111827));
    });

    testWidgets('should set fixed heights for control bars', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitPriorityLayout(
            primaryActionBar: mockPrimaryActionBar,
            content: mockContent,
            secondaryControlBar: mockSecondaryControlBar,
          ),
        ),
      );

      // Check that primary and secondary action bars are rendered with correct layout heights
      final primarySize = tester.getSize(find.byKey(const Key('primary-action-bar')));
      final secondarySize = tester.getSize(find.byKey(const Key('secondary-control-bar')));

      expect(primarySize.height, 70); // The layout container height
      expect(secondarySize.height, 70); // The layout container height
    });

    testWidgets('should show progress indicator when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitPriorityLayout(
            primaryActionBar: mockPrimaryActionBar,
            content: mockContent,
            secondaryControlBar: mockSecondaryControlBar,
            showProgressIndicator: true,
            progress: 0.6,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.6);
      expect(progressIndicator.backgroundColor, const Color(0xFF1f2937));
      expect(progressIndicator.minHeight, 8);
    });

    testWidgets('should hide progress indicator when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitPriorityLayout(
            primaryActionBar: mockPrimaryActionBar,
            content: mockContent,
            secondaryControlBar: mockSecondaryControlBar,
            showProgressIndicator: false,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    group('Responsive Behavior', () {
      testWidgets('should adapt to small screen height', (WidgetTester tester) async {
        // Set small screen size
        await tester.binding.setSurfaceSize(const Size(400, 500));
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplitPriorityLayout(
              primaryActionBar: mockPrimaryActionBar,
              content: mockContent,
              secondaryControlBar: mockSecondaryControlBar,
            ),
          ),
        );

        // Verify layout still renders correctly with constrained height
        expect(find.byKey(const Key('primary-action-bar')), findsOneWidget);
        expect(find.byKey(const Key('content-area')), findsOneWidget);
        expect(find.byKey(const Key('secondary-control-bar')), findsOneWidget);
        
        // Content area should still be expandable
        expect(find.byType(Expanded), findsOneWidget);
      });

      testWidgets('should handle large screen size', (WidgetTester tester) async {
        // Set large screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplitPriorityLayout(
              primaryActionBar: mockPrimaryActionBar,
              content: mockContent,
              secondaryControlBar: mockSecondaryControlBar,
            ),
          ),
        );

        // Verify all components render on large screens
        expect(find.byKey(const Key('primary-action-bar')), findsOneWidget);
        expect(find.byKey(const Key('content-area')), findsOneWidget);
        expect(find.byKey(const Key('secondary-control-bar')), findsOneWidget);
      });

      testWidgets('should maintain minimum control bar heights', (WidgetTester tester) async {
        // Test with very small screen
        await tester.binding.setSurfaceSize(const Size(300, 400));
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplitPriorityLayout(
              primaryActionBar: mockPrimaryActionBar,
              content: mockContent,
              secondaryControlBar: mockSecondaryControlBar,
            ),
          ),
        );

        // Control bars should maintain their height even on small screens
        final primarySize = tester.getSize(find.byKey(const Key('primary-action-bar')));
        final secondarySize = tester.getSize(find.byKey(const Key('secondary-control-bar')));

        expect(primarySize.height, 70); // The layout container height
        expect(secondarySize.height, 70); // The layout container height
      });
    });

    group('MediaQuery Integration', () {
      testWidgets('should access MediaQuery for responsive calculations', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SplitPriorityLayout(
              primaryActionBar: mockPrimaryActionBar,
              content: mockContent,
              secondaryControlBar: mockSecondaryControlBar,
            ),
          ),
        );

        // Verify MediaQuery is accessible (implicitly tested by responsive behavior)
        expect(find.byType(SplitPriorityLayout), findsOneWidget);
      });
    });


  });
} 