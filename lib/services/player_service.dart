import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/player.dart';

class PlayerService {
  static PlayerService _instance = PlayerService._();
  static PlayerService get instance => _instance;

  // Allow replacement for testing
  static void setInstance(PlayerService instance) {
    _instance = instance;
  }

  PlayerService._();

  static const String _playersFileName = 'players.json';
  List<Player> _players = [];
  bool _isLoaded = false;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getPlayersFile() async {
    final path = await _localPath;
    return File('$path/$_playersFileName');
  }

  /// Loads player data from local storage on app start
  Future<void> loadPlayers() async {
    if (_isLoaded) return;

    try {
      final file = await _getPlayersFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _players = jsonList.map((json) => Player.fromJson(json)).toList();
      }
      _isLoaded = true;
    } catch (e) {
      print('Error loading players: $e');
      _players = [];
      _isLoaded = true;
    }
  }

  /// Saves player data to local storage after any change
  Future<void> savePlayers() async {
    try {
      final file = await _getPlayersFile();
      final jsonList = _players.map((player) => player.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving players: $e');
      throw Exception('Failed to save players: $e');
    }
  }

  /// Adds a new player. Returns error if name is empty or duplicate
  Future<String?> addPlayer(String name) async {
    await loadPlayers();

    // Validate name
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Player name cannot be empty';
    }

    // Check for duplicates
    if (_players.any((player) => 
        player.name.toLowerCase() == trimmedName.toLowerCase())) {
      return 'A player with this name already exists';
    }

    // Add the player
    final newPlayer = Player.create(name: trimmedName);
    _players.add(newPlayer);

    // Save to disk
    await savePlayers();
    return null; // Success
  }

  /// Returns a list of all registered players
  Future<List<Player>> getPlayers() async {
    await loadPlayers();
    return List.unmodifiable(_players);
  }

  /// Removes a player by ID
  Future<String?> removePlayer(String id) async {
    await loadPlayers();

    final initialLength = _players.length;
    _players.removeWhere((player) => player.id == id);

    if (_players.length == initialLength) {
      return 'Player not found';
    }

    await savePlayers();
    return null; // Success
  }

  /// Updates a player's name. Checks for duplicates
  Future<String?> updatePlayer(String id, String newName) async {
    await loadPlayers();

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return 'Player name cannot be empty';
    }

    // Find the player
    final playerIndex = _players.indexWhere((player) => player.id == id);
    if (playerIndex == -1) {
      return 'Player not found';
    }

    // Check for duplicates (excluding the current player)
    if (_players.any((player) => 
        player.id != id && 
        player.name.toLowerCase() == trimmedName.toLowerCase())) {
      return 'A player with this name already exists';
    }

    // Update the player
    _players[playerIndex] = _players[playerIndex].copyWith(name: trimmedName);

    await savePlayers();
    return null; // Success
  }

  /// Adds a batch of players for pre-registration
  Future<Map<String, String>> preRegisterPlayers(List<String> names) async {
    await loadPlayers();

    final Map<String, String> results = {};

    for (final name in names) {
      final error = await addPlayer(name);
      if (error != null) {
        results[name] = error;
      }
    }

    return results; // Returns any errors by player name
  }

  /// Returns player(s) matching the name
  Future<List<Player>> findPlayerByName(String name) async {
    await loadPlayers();

    final searchTerm = name.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      return [];
    }

    return _players.where((player) => 
        player.name.toLowerCase().contains(searchTerm)).toList();
  }

  /// Clears all players (useful for testing)
  Future<void> clearAllPlayers() async {
    _players = [];
    await savePlayers();
  }
}