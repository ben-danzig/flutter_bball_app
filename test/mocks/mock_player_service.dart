import 'package:flutter_bball_app/models/player.dart';

class MockPlayerService {
  List<Player> mockPlayers = [];
  String? lastAddedPlayerName;
  String? lastRemovedPlayerId;
  String? lastUpdatedPlayerId;
  String? lastUpdatedPlayerName;
  Map<String, String>? lastPreRegisterErrors;
  String? lastSearchTerm;
  bool loadPlayersCalled = false;
  bool savePlayersCalled = false;

  MockPlayerService();

  Future<void> loadPlayers() async {
    loadPlayersCalled = true;
  }

  Future<void> savePlayers() async {
    savePlayersCalled = true;
  }

  Future<String?> addPlayer(String name) async {
    lastAddedPlayerName = name;
    
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Player name cannot be empty';
    }

    if (mockPlayers.any((p) => 
        p.name.toLowerCase() == trimmedName.toLowerCase())) {
      return 'A player with this name already exists';
    }

    mockPlayers.add(Player.create(name: trimmedName));
    return null;
  }

  Future<List<Player>> getPlayers() async {
    return List.unmodifiable(mockPlayers);
  }

  Future<String?> removePlayer(String id) async {
    lastRemovedPlayerId = id;
    
    final initialLength = mockPlayers.length;
    mockPlayers.removeWhere((p) => p.id == id);
    
    if (mockPlayers.length == initialLength) {
      return 'Player not found';
    }
    
    return null;
  }

  Future<String?> updatePlayer(String id, String newName) async {
    lastUpdatedPlayerId = id;
    lastUpdatedPlayerName = newName;
    
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return 'Player name cannot be empty';
    }

    final playerIndex = mockPlayers.indexWhere((p) => p.id == id);
    if (playerIndex == -1) {
      return 'Player not found';
    }

    if (mockPlayers.any((p) => 
        p.id != id && 
        p.name.toLowerCase() == trimmedName.toLowerCase())) {
      return 'A player with this name already exists';
    }

    mockPlayers[playerIndex] = mockPlayers[playerIndex].copyWith(name: trimmedName);
    return null;
  }

  Future<Map<String, String>> preRegisterPlayers(List<String> names) async {
    final Map<String, String> errors = {};
    
    for (final name in names) {
      final error = await addPlayer(name);
      if (error != null) {
        errors[name] = error;
      }
    }
    
    lastPreRegisterErrors = errors;
    return errors;
  }

  Future<List<Player>> findPlayerByName(String name) async {
    lastSearchTerm = name;
    
    final searchTerm = name.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      return [];
    }

    return mockPlayers.where((p) => 
        p.name.toLowerCase().contains(searchTerm)).toList();
  }

  Future<void> clearAllPlayers() async {
    mockPlayers.clear();
  }

  // Helper methods for tests
  void setMockPlayers(List<Player> players) {
    mockPlayers = List.from(players);
  }

  void reset() {
    mockPlayers.clear();
    lastAddedPlayerName = null;
    lastRemovedPlayerId = null;
    lastUpdatedPlayerId = null;
    lastUpdatedPlayerName = null;
    lastPreRegisterErrors = null;
    lastSearchTerm = null;
    loadPlayersCalled = false;
    savePlayersCalled = false;
  }
}