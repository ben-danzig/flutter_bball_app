import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bball_app/screens/workout_builder/drill_library_screen.dart';
import 'package:flutter_bball_app/services/drill_library_service.dart';
import 'package:flutter_bball_app/models/drill_template.dart';
import 'package:flutter_bball_app/models/drill.dart';

@GenerateMocks([DrillLibraryService])
import 'drill_library_screen_test.mocks.dart';

void main() {
  group('DrillLibraryScreen', () {
    late MockDrillLibraryService mockService;
    late List<DrillTemplate> testTemplates;

    setUp(() {
      mockService = MockDrillLibraryService();
      
      testTemplates = [
        DrillTemplate(
          id: 'template_1',
          name: 'Basic Dribbling',
          description: 'Practice basic dribbling moves',
          type: 'TIMED',
          category: 'Ball Handling',
          difficulty: 'beginner',
          tags: ['dribbling', 'basics'],
          defaultConfig: {'duration': 60, 'sets': 3},
          configOptions: {
            'duration': {'min': 30, 'max': 300, 'step': 15},
            'sets': {'min': 1, 'max': 5, 'step': 1},
          },
        ),
        DrillTemplate(
          id: 'template_2',
          name: 'Free Throw Practice',
          description: 'Practice free throws',
          type: 'REP_BASED',
          category: 'Shooting',
          difficulty: 'beginner',
          tags: ['shooting', 'free throws'],
          defaultConfig: {'targetMakes': 10, 'sets': 5},
          configOptions: {
            'targetMakes': {'min': 5, 'max': 50, 'step': 5},
            'sets': {'min': 1, 'max': 10, 'step': 1},
          },
        ),
        DrillTemplate(
          id: 'template_3',
          name: 'Advanced Ball Control',
          description: 'Complex dribbling combinations',
          type: 'TIMED',
          category: 'Ball Handling',
          difficulty: 'advanced',
          tags: ['dribbling', 'advanced'],
          defaultConfig: {'duration': 120, 'sets': 2},
          configOptions: {
            'duration': {'min': 60, 'max': 300, 'step': 30},
            'sets': {'min': 1, 'max': 4, 'step': 1},
          },
        ),
      ];

      // Setup default mock responses
      when(mockService.getAllTemplates())
          .thenAnswer((_) async => testTemplates);
      when(mockService.getCategories())
          .thenAnswer((_) async => ['Ball Handling', 'Shooting']);
      when(mockService.getDifficulties())
          .thenAnswer((_) async => ['beginner', 'intermediate', 'advanced']);
      when(mockService.getDrillTypes())
          .thenAnswer((_) async => ['TIMED', 'REP_BASED', 'MAKE_TARGET_TIMED', 'READ_AND_REACT']);
    });

    Widget createTestWidget({Function(Drill)? onDrillSelected}) {
      return MaterialApp(
        home: Provider<DrillLibraryService>.value(
          value: mockService,
          child: DrillLibraryScreen(
            onDrillSelected: onDrillSelected ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('displays drill templates in a grid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that drill templates are displayed
      expect(find.text('Basic Dribbling'), findsOneWidget);
      expect(find.text('Free Throw Practice'), findsOneWidget);
      expect(find.text('Advanced Ball Control'), findsOneWidget);

      // Check that descriptions are displayed
      expect(find.text('Practice basic dribbling moves'), findsOneWidget);
      expect(find.text('Practice free throws'), findsOneWidget);
    });

    testWidgets('displays search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for filter button
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Tap filter button to show filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Check for category filter chips
      expect(find.text('Ball Handling'), findsWidgets);
      expect(find.text('Shooting'), findsWidgets);

      // Check for difficulty filter chips
      expect(find.text('beginner'), findsWidgets);
      expect(find.text('intermediate'), findsOneWidget);
      expect(find.text('advanced'), findsWidgets);
    });

    testWidgets('searches drills by name', (WidgetTester tester) async {
      when(mockService.searchTemplates('dribbling'))
          .thenAnswer((_) async => [testTemplates[0], testTemplates[2]]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'dribbling');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Verify search was called
      verify(mockService.searchTemplates('dribbling')).called(1);

      // Check that only matching drills are displayed
      expect(find.text('Basic Dribbling'), findsOneWidget);
      expect(find.text('Advanced Ball Control'), findsOneWidget);
      expect(find.text('Free Throw Practice'), findsNothing);
    });

    testWidgets('filters drills by category', (WidgetTester tester) async {
      when(mockService.filterTemplates(category: 'Ball Handling'))
          .thenAnswer((_) async => [testTemplates[0], testTemplates[2]]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select Ball Handling category
      await tester.tap(find.widgetWithText(FilterChip, 'Ball Handling').first);
      await tester.pumpAndSettle();

      // Verify filter was applied
      verify(mockService.filterTemplates(category: 'Ball Handling')).called(1);
    });

    testWidgets('filters drills by difficulty', (WidgetTester tester) async {
      when(mockService.filterTemplates(difficulty: 'beginner'))
          .thenAnswer((_) async => [testTemplates[0], testTemplates[1]]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select beginner difficulty
      await tester.tap(find.widgetWithText(FilterChip, 'beginner').first);
      await tester.pumpAndSettle();

      // Verify filter was applied
      verify(mockService.filterTemplates(difficulty: 'beginner')).called(1);
    });

    testWidgets('shows drill details on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on a drill template
      await tester.tap(find.text('Basic Dribbling'));
      await tester.pumpAndSettle();

      // Check that details dialog/sheet is shown
      expect(find.text('Drill Details'), findsOneWidget);
      expect(find.text('Type: TIMED'), findsOneWidget);
      expect(find.text('Category: Ball Handling'), findsOneWidget);
      expect(find.text('Difficulty: beginner'), findsOneWidget);
      expect(find.text('Tags: dribbling, basics'), findsOneWidget);
    });

    testWidgets('allows drill selection', (WidgetTester tester) async {
      Drill? selectedDrill;
      
      await tester.pumpWidget(createTestWidget(
        onDrillSelected: (drill) {
          selectedDrill = drill;
        },
      ));
      await tester.pumpAndSettle();

      // Setup mock for drill creation
      final expectedDrill = Drill(
        drillId: 'generated_id',
        name: 'Basic Dribbling',
        description: 'Practice basic dribbling moves',
        type: 'TIMED',
        config: {'duration': 60, 'sets': 3},
      );
      
      when(mockService.createDrillFromTemplate(any))
          .thenAnswer((_) async => expectedDrill);

      // Tap on a drill template
      await tester.tap(find.text('Basic Dribbling'));
      await tester.pumpAndSettle();

      // Tap select button
      await tester.tap(find.text('Select Drill'));
      await tester.pumpAndSettle();

      // Verify drill was created and selected
      expect(selectedDrill, isNotNull);
      expect(selectedDrill?.name, 'Basic Dribbling');
    });

    testWidgets('shows empty state when no drills match filters', (WidgetTester tester) async {
      when(mockService.filterTemplates(category: 'Defense'))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select Defense category (which has no drills)
      when(mockService.getCategories())
          .thenAnswer((_) async => ['Ball Handling', 'Shooting', 'Defense']);
      
      // Simulate empty results
      when(mockService.getAllTemplates()).thenAnswer((_) async => []);
      await tester.pumpAndSettle();

      // Check for empty state message
      expect(find.text('No drills found'), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching drills', (WidgetTester tester) async {
      // Make the service return a delayed future
      when(mockService.getAllTemplates()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return testTemplates;
      });

      await tester.pumpWidget(createTestWidget());

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Check that drills are now displayed
      expect(find.text('Basic Dribbling'), findsOneWidget);
    });

    testWidgets('clears filters when clear button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select a filter
      await tester.tap(find.widgetWithText(FilterChip, 'Ball Handling').first);
      await tester.pumpAndSettle();

      // Tap clear filters
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      // Verify all templates are shown again
      verify(mockService.getAllTemplates()).called(greaterThan(1));
    });

    testWidgets('displays drill type badges', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for type badges
      expect(find.text('TIMED'), findsWidgets);
      expect(find.text('REP_BASED'), findsOneWidget);
    });

    testWidgets('displays difficulty indicators', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for difficulty indicators (could be icons or colored badges)
      expect(find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color != null
      ), findsWidgets);
    });

    testWidgets('allows custom configuration before selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on a drill template
      await tester.tap(find.text('Basic Dribbling'));
      await tester.pumpAndSettle();

      // Check for configuration options
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Sets'), findsOneWidget);

      // Modify configuration
      await tester.tap(find.byType(Slider).first);
      await tester.pumpAndSettle();

      // Verify custom config can be applied
      when(mockService.createDrillFromTemplate(
        any,
        customConfig: anyNamed('customConfig'),
      )).thenAnswer((_) async => Drill(
        drillId: 'custom_id',
        name: 'Basic Dribbling',
        description: 'Practice basic dribbling moves',
        type: 'TIMED',
        config: {'duration': 90, 'sets': 3},
      ));
    });

    testWidgets('handles errors gracefully', (WidgetTester tester) async {
      when(mockService.getAllTemplates())
          .thenThrow(Exception('Failed to load drills'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Failed to load drills'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Tap retry button
      when(mockService.getAllTemplates())
          .thenAnswer((_) async => testTemplates);
      
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Check that drills are now displayed
      expect(find.text('Basic Dribbling'), findsOneWidget);
    });
  });
}