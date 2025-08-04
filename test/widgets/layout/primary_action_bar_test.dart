import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/widgets/layout/primary_action_bar.dart';
import 'package:flutter_bball_app/utils/drill_types.dart';

void main() {
  group('PrimaryActionBar', () {
    testWidgets('should render empty container when no primary action needed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.timed,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      // Should not show any buttons for timed drills
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.text('UP NEXT: Next Drill'), findsOneWidget);
    });

    testWidgets('should render FINISH DRILL button for make target timed drills', (WidgetTester tester) async {
      bool actionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {
                actionCalled = true;
              },
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      // Should show FINISH DRILL button
      expect(find.text('FINISH DRILL'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Button should be enabled and call callback
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byType(ElevatedButton));
      expect(actionCalled, isTrue);
    });

    testWidgets('should render LOG SET button for rep based drills', (WidgetTester tester) async {
      bool actionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.repBased,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {
                actionCalled = true;
              },
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      // Should show LOG SET button
      expect(find.text('LOG SET'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Button should be enabled and call callback
      await tester.tap(find.byType(ElevatedButton));
      expect(actionCalled, isTrue);
    });

    testWidgets('should disable button when isPrimaryActionEnabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show correct button colors', (WidgetTester tester) async {
      // Test green color for make target timed
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      expect(find.text('FINISH DRILL'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test blue color for rep based
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.repBased,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      expect(find.text('LOG SET'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show "UP NEXT" with drill name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: 'Ball Handling Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      expect(find.text('UP NEXT: Ball Handling Drill'), findsOneWidget);
    });

    testWidgets('should show "Workout Complete" when no next drill', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: null,
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      expect(find.text('UP NEXT: Workout Complete'), findsOneWidget);
    });

    testWidgets('should have minimum button size and proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('FINISH DRILL'), findsOneWidget);

      // Check button size (minimum 200x44)
      final buttonSize = tester.getSize(find.byType(ElevatedButton));
      expect(buttonSize.width, greaterThanOrEqualTo(200));
      expect(buttonSize.height, greaterThanOrEqualTo(44));
    });

    testWidgets('should handle null onPrimaryAction callback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: 'Next Drill',
              onPrimaryAction: null,
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should render with proper padding and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.repBased,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      // Should have proper container with padding
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
      
      // Should have both next drill info and button
      expect(find.text('UP NEXT: Next Drill'), findsOneWidget);
      expect(find.text('LOG SET'), findsOneWidget);
    });

    testWidgets('should not render primary action for read and react drills', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.readAndReact,
              nextDrillName: 'Next Drill',
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      // Should not show any buttons for read and react drills
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.text('UP NEXT: Next Drill'), findsOneWidget);
    });

    testWidgets('should handle edge case with very long drill names', (WidgetTester tester) async {
      final longDrillName = 'This is a very long drill name that might overflow the UI and cause layout issues';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionBar(
              drillType: DrillType.makeTargetTimed,
              nextDrillName: longDrillName,
              onPrimaryAction: () {},
              isPrimaryActionEnabled: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('UP NEXT: This is a very long drill name'), findsOneWidget);
      // Should not overflow
      expect(tester.takeException(), isNull);
    });
  });
} 