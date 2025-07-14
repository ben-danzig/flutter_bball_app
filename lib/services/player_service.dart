import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class PlayerService {
  static PlayerService _instance = PlayerService._();
  static PlayerService get instance => _instance;

  // Allow replacement for testing
  static void setInstance(PlayerService instance) {
    _instance = instance;
  }

  PlayerService._();

  final CollectionReference _playersRef = FirebaseFirestore.instance.collection('players');

  /// Adds a new player. Returns error if name is empty or duplicate
  Future<String?> addPlayer(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Player name cannot be empty';
    }

    // Check for duplicates (case-insensitive)
    final query = await _playersRef.where('name', isEqualTo: trimmedName).get();
    if (query.docs.isNotEmpty) {
      return 'A player with this name already exists';
    }

    final newPlayer = Player.create(name: trimmedName);
    await _playersRef.doc(newPlayer.id).set(newPlayer.toJson());
    return null; // Success
  }

  /// Returns a list of all registered players
  Future<List<Player>> getPlayers() async {
    final snapshot = await _playersRef.orderBy('registeredAt').get();
    return snapshot.docs.map((doc) => Player.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  /// Removes a player by ID
  Future<String?> removePlayer(String id) async {
    final doc = await _playersRef.doc(id).get();
    if (!doc.exists) {
      return 'Player not found';
    }
    await _playersRef.doc(id).delete();
    return null; // Success
  }

  /// Updates a player's name. Checks for duplicates
  Future<String?> updatePlayer(String id, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return 'Player name cannot be empty';
    }

    final doc = await _playersRef.doc(id).get();
    if (!doc.exists) {
      return 'Player not found';
    }

    // Check for duplicates (excluding the current player)
    final query = await _playersRef.where('name', isEqualTo: trimmedName).get();
    if (query.docs.any((d) => d.id != id)) {
      return 'A player with this name already exists';
    }

    await _playersRef.doc(id).update({'name': trimmedName});
    return null; // Success
  }

  /// Returns player(s) matching the name (partial, case-insensitive)
  Future<List<Player>> findPlayerByName(String name) async {
    final searchTerm = name.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      return [];
    }
    final snapshot = await _playersRef.get();
    return snapshot.docs
        .map((doc) => Player.fromJson(doc.data() as Map<String, dynamic>))
        .where((player) => player.name.toLowerCase().contains(searchTerm))
        .toList();
  }

  /// No-op for Firestore, but kept for API compatibility
  Future<void> loadPlayers() async {}
  Future<void> savePlayers() async {}
  Future<void> clearAllPlayers() async {
    final snapshot = await _playersRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}