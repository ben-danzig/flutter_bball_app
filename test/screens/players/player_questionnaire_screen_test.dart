import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/screens/players/player_questionnaire_screen.dart';
import 'package:flutter_bball_app/models/player.dart';
import '../../mocks/mock_player_service.dart';

void main() {
  group('PlayerQuestionnaireScreen', () {
    late MockPlayerService mockPlayerService;
    late Player testPlayer;

    setUp(() {
      mockPlayerService = MockPlayerService();
      testPlayer = Player.create(name: 'Test Player');
      mockPlayerService.setMockPlayers([testPlayer]);
    });

    testWidgets('should display questionnaire form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      // Verify the screen title is displayed
      expect(find.text('Player Questionnaire'), findsOneWidget);
      
      // Verify the BRO System introduction is displayed
      expect(find.text('BRO System'), findsOneWidget);
      expect(find.text('Basketball Roster Optimizer'), findsOneWidget);
      
      // Verify all questions are displayed
      expect(find.text('Is there someone in particular you\'d like to be paired with?'), findsOneWidget);
      expect(find.text('What is your height?'), findsOneWidget);
      expect(find.text('What\'s the highest level of basketball you\'ve played?'), findsOneWidget);
      expect(find.text('Can you consistently make an open layup?'), findsOneWidget);
      expect(find.text('When was the last time you touched a basketball?'), findsOneWidget);
      expect(find.text('Any additional pleas you\'d like to make to the algorithm?'), findsOneWidget);
      
      // Verify submit button is displayed
      expect(find.text('Submit Questionnaire'), findsOneWidget);
    });

    testWidgets('should show cancel button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      // Try to submit without filling required fields
      await tester.tap(find.text('Submit Questionnaire'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter your height'), findsOneWidget);
    });

    testWidgets('should allow height input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      // Find height input fields
      final feetField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'Feet',
      );
      final inchesField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'Inches',
      );

      expect(feetField, findsOneWidget);
      expect(inchesField, findsOneWidget);

      // Enter height values
      await tester.enterText(feetField, '6');
      await tester.enterText(inchesField, '2');
      await tester.pump();

      expect(find.text('6'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should show dropdown options for basketball level', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      // Find the dropdown for highest level played
      final dropdown = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String>,
      );

      expect(dropdown, findsWidgets);

      // Tap the dropdown to open it
      await tester.tap(dropdown.first);
      await tester.pumpAndSettle();

      // Verify options are displayed
      expect(find.text('just playing some bball outside of the school'), findsOneWidget);
      expect(find.text('HS'), findsOneWidget);
      expect(find.text('College'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
    });

    testWidgets('should show dropdown options for layup ability', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      // Find the dropdown for layup ability (second dropdown)
      final dropdowns = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String>,
      );

      expect(dropdowns, findsWidgets);

      // Tap the second dropdown (layup ability)
      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();

      // Verify options are displayed
      expect(find.text('yeah definitely'), findsOneWidget);
      expect(find.text('i think so'), findsOneWidget);
      expect(find.text('dont count on me'), findsOneWidget);
    });

    testWidgets('should show dropdown options for last time played', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerQuestionnaireScreen(player: testPlayer),
        ),
      );

      // Find the dropdown for last time played (third dropdown)
      final dropdowns = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<String>,
      );

      expect(dropdowns, findsWidgets);

      // Tap the third dropdown (last time played)
      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();

      // Verify options are displayed
      expect(find.text('within the last week'), findsOneWidget);
      expect(find.text('within the last few months'), findsOneWidget);
      expect(find.text('man it\'s been years'), findsOneWidget);
      expect(find.text('what the hell is that orange crap??'), findsOneWidget);
    });
  });
} 