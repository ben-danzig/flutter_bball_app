import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/models/player.dart';
import 'package:flutter_bball_app/screens/players/team_pairing_screen.dart';
import 'package:flutter_bball_app/test/mocks/mock_player_service.dart';

void main() {
  group('TeamPairingScreen', () {
    late MockPlayerService mockPlayerService;

    setUp(() {
      mockPlayerService = MockPlayerService();
      // Set up some mock players
      mockPlayerService.setMockPlayers([
        Player.create(name: 'Player 1'),
        Player.create(name: 'Player 2'),
        Player.create(name: 'Player 3'),
        Player.create(name: 'Player 4'),
      ]);
    });

    testWidgets('should display available players', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const TeamPairingScreen(),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that players are displayed
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.text('Player 3'), findsOneWidget);
      expect(find.text('Player 4'), findsOneWidget);
    });

    testWidgets('should show empty state when no players', (WidgetTester tester) async {
      mockPlayerService.setMockPlayers([]);
      
      await tester.pumpWidget(
        MaterialApp(
          home: const TeamPairingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No players available'), findsOneWidget);
    });

    testWidgets('should display team pairing interface', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const TeamPairingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the interface elements are present
      expect(find.text('Available Players'), findsOneWidget);
      expect(find.text('Teams (Drag players here)'), findsOneWidget);
      expect(find.text('Drag players here to create teams'), findsOneWidget);
    });
  });
} 