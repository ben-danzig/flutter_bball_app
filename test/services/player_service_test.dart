import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/player.dart';
import 'package:flutter_bball_app/services/player_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PlayerService playerService;
  late Directory tempDir;

  setUp(() async {
    playerService = PlayerService.instance;
    tempDir = await Directory.systemTemp.createTemp();

    // Mock the path_provider platform channel
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    // Clear any existing players for a clean test state
    await playerService.clearAllPlayers();
  });

  tearDown(() async {
    // Delete the temporary directory and all its contents
    await tempDir.delete(recursive: true);
    // Clear the mock handler
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('addPlayer', () {
    test('should add a new player successfully', () async {
      // ARRANGE
      const playerName = 'John Doe';

      // ACT
      final error = await playerService.addPlayer(playerName);
      final players = await playerService.getPlayers();

      // ASSERT
      expect(error, isNull);
      expect(players.length, 1);
      expect(players.first.name, playerName);
      expect(players.first.id, isNotEmpty);
      expect(players.first.registeredAt, isA<DateTime>());
    });

    test('should return error for empty name', () async {
      // ACT
      final error = await playerService.addPlayer('');

      // ASSERT
      expect(error, 'Player name cannot be empty');
    });

    test('should return error for whitespace-only name', () async {
      // ACT
      final error = await playerService.addPlayer('   ');

      // ASSERT
      expect(error, 'Player name cannot be empty');
    });

    test('should return error for duplicate name', () async {
      // ARRANGE
      const playerName = 'John Doe';
      await playerService.addPlayer(playerName);

      // ACT
      final error = await playerService.addPlayer(playerName);

      // ASSERT
      expect(error, 'A player with this name already exists');
    });

    test('should check duplicates case-insensitively', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');

      // ACT
      final error = await playerService.addPlayer('john doe');

      // ASSERT
      expect(error, 'A player with this name already exists');
    });

    test('should trim whitespace from names', () async {
      // ACT
      await playerService.addPlayer('  John Doe  ');
      final players = await playerService.getPlayers();

      // ASSERT
      expect(players.first.name, 'John Doe');
    });
  });

  group('getPlayers', () {
    test('should return empty list when no players exist', () async {
      // ACT
      final players = await playerService.getPlayers();

      // ASSERT
      expect(players, isEmpty);
    });

    test('should return all registered players', () async {
      // ARRANGE
      await playerService.addPlayer('Player 1');
      await playerService.addPlayer('Player 2');
      await playerService.addPlayer('Player 3');

      // ACT
      final players = await playerService.getPlayers();

      // ASSERT
      expect(players.length, 3);
      expect(players.map((p) => p.name), containsAll(['Player 1', 'Player 2', 'Player 3']));
    });
  });

  group('removePlayer', () {
    test('should remove player successfully', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');
      final players = await playerService.getPlayers();
      final playerId = players.first.id;

      // ACT
      final error = await playerService.removePlayer(playerId);
      final updatedPlayers = await playerService.getPlayers();

      // ASSERT
      expect(error, isNull);
      expect(updatedPlayers, isEmpty);
    });

    test('should return error for non-existent player', () async {
      // ACT
      final error = await playerService.removePlayer('non-existent-id');

      // ASSERT
      expect(error, 'Player not found');
    });
  });

  group('updatePlayer', () {
    test('should update player name successfully', () async {
      // ARRANGE
      await playerService.addPlayer('Old Name');
      final players = await playerService.getPlayers();
      final playerId = players.first.id;

      // ACT
      final error = await playerService.updatePlayer(playerId, 'New Name');
      final updatedPlayers = await playerService.getPlayers();

      // ASSERT
      expect(error, isNull);
      expect(updatedPlayers.first.name, 'New Name');
      expect(updatedPlayers.first.id, playerId); // ID should remain the same
    });

    test('should return error for empty new name', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');
      final players = await playerService.getPlayers();
      final playerId = players.first.id;

      // ACT
      final error = await playerService.updatePlayer(playerId, '');

      // ASSERT
      expect(error, 'Player name cannot be empty');
    });

    test('should return error for non-existent player', () async {
      // ACT
      final error = await playerService.updatePlayer('non-existent-id', 'New Name');

      // ASSERT
      expect(error, 'Player not found');
    });

    test('should return error when updating to duplicate name', () async {
      // ARRANGE
      await playerService.addPlayer('Player 1');
      await playerService.addPlayer('Player 2');
      final players = await playerService.getPlayers();
      final player2Id = players.firstWhere((p) => p.name == 'Player 2').id;

      // ACT
      final error = await playerService.updatePlayer(player2Id, 'Player 1');

      // ASSERT
      expect(error, 'A player with this name already exists');
    });
  });

  group('preRegisterPlayers', () {
    test('should add multiple players successfully', () async {
      // ARRANGE
      final names = ['Player 1', 'Player 2', 'Player 3'];

      // ACT
      final errors = await playerService.preRegisterPlayers(names);
      final players = await playerService.getPlayers();

      // ASSERT
      expect(errors, isEmpty);
      expect(players.length, 3);
      expect(players.map((p) => p.name), containsAll(names));
    });

    test('should return errors for invalid players only', () async {
      // ARRANGE
      final names = ['Valid Player', '', 'Another Valid', 'Valid Player'];

      // ACT
      final errors = await playerService.preRegisterPlayers(names);
      final players = await playerService.getPlayers();

      // ASSERT
      expect(errors.length, 2);
      expect(errors[''], 'Player name cannot be empty');
      expect(errors['Valid Player'], 'A player with this name already exists');
      expect(players.length, 2);
    });
  });

  group('findPlayerByName', () {
    test('should find players by partial name match', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');
      await playerService.addPlayer('Jane Doe');
      await playerService.addPlayer('Bob Smith');

      // ACT
      final results = await playerService.findPlayerByName('Doe');

      // ASSERT
      expect(results.length, 2);
      expect(results.map((p) => p.name), containsAll(['John Doe', 'Jane Doe']));
    });

    test('should search case-insensitively', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');

      // ACT
      final results = await playerService.findPlayerByName('john');

      // ASSERT
      expect(results.length, 1);
      expect(results.first.name, 'John Doe');
    });

    test('should return empty list for empty search term', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');

      // ACT
      final results = await playerService.findPlayerByName('');

      // ASSERT
      expect(results, isEmpty);
    });

    test('should return empty list when no matches found', () async {
      // ARRANGE
      await playerService.addPlayer('John Doe');

      // ACT
      final results = await playerService.findPlayerByName('Smith');

      // ASSERT
      expect(results, isEmpty);
    });
  });

  group('persistence', () {
    test('should persist players to disk and load them on startup', () async {
      // ARRANGE
      await playerService.addPlayer('Persistent Player');
      
      // Create a new instance to simulate app restart
      final newPlayerService = PlayerService();
      PlayerService.setInstance(newPlayerService);

      // ACT
      final players = await newPlayerService.getPlayers();

      // ASSERT
      expect(players.length, 1);
      expect(players.first.name, 'Persistent Player');
    });

    test('should handle corrupted JSON file gracefully', () async {
      // ARRANGE
      final file = File('${tempDir.path}/players.json');
      await file.writeAsString('corrupted json data');

      // ACT
      final players = await playerService.getPlayers();

      // ASSERT
      expect(players, isEmpty); // Should handle error and return empty list
    });
  });
}