# Player Storage API Documentation

## Overview

The Player Storage Agent provides a comprehensive API for managing player data in the 2-on-2 basketball tournament app. All player data is stored locally on the device using JSON files.

## Service Access

The `PlayerService` is implemented as a singleton and can be accessed via:

```dart
import 'package:flutter_bball_app/services/player_service.dart';

final playerService = PlayerService.instance;
```

## API Methods

### 1. Load Players

**Method:** `loadPlayers()`

**Description:** Loads player data from local storage. This is called automatically when using other methods, but can be called explicitly on app startup.

**Usage:**
```dart
await playerService.loadPlayers();
```

**Returns:** `Future<void>`

---

### 2. Add Player

**Method:** `addPlayer(String name)`

**Description:** Adds a new player to the registry.

**Parameters:**
- `name` (String): The player's name

**Returns:** `Future<String?>` - Returns `null` on success, or an error message on failure

**Error Cases:**
- Empty or whitespace-only name: `"Player name cannot be empty"`
- Duplicate name (case-insensitive): `"A player with this name already exists"`

**Usage:**
```dart
final error = await playerService.addPlayer("John Doe");
if (error != null) {
  // Handle error
  print(error);
} else {
  // Success
}
```

---

### 3. Get All Players

**Method:** `getPlayers()`

**Description:** Returns a list of all registered players.

**Returns:** `Future<List<Player>>` - An unmodifiable list of Player objects

**Usage:**
```dart
final players = await playerService.getPlayers();
for (final player in players) {
  print('${player.name} (ID: ${player.id})');
}
```

---

### 4. Remove Player

**Method:** `removePlayer(String id)`

**Description:** Removes a player from the registry.

**Parameters:**
- `id` (String): The unique player ID

**Returns:** `Future<String?>` - Returns `null` on success, or an error message on failure

**Error Cases:**
- Player not found: `"Player not found"`

**Usage:**
```dart
final error = await playerService.removePlayer(playerId);
if (error != null) {
  print(error);
}
```

---

### 5. Update Player

**Method:** `updatePlayer(String id, String newName)`

**Description:** Updates a player's name.

**Parameters:**
- `id` (String): The unique player ID
- `newName` (String): The new name for the player

**Returns:** `Future<String?>` - Returns `null` on success, or an error message on failure

**Error Cases:**
- Empty name: `"Player name cannot be empty"`
- Player not found: `"Player not found"`
- Duplicate name: `"A player with this name already exists"`

**Usage:**
```dart
final error = await playerService.updatePlayer(playerId, "Jane Doe");
if (error != null) {
  print(error);
}
```

---

### 6. Pre-register Players

**Method:** `preRegisterPlayers(List<String> names)`

**Description:** Adds multiple players in batch. Useful for tournament organizers to pre-register participants.

**Parameters:**
- `names` (List<String>): List of player names to register

**Returns:** `Future<Map<String, String>>` - A map of player names to error messages (only for failed registrations)

**Usage:**
```dart
final names = ["Player 1", "Player 2", "Player 3"];
final errors = await playerService.preRegisterPlayers(names);

if (errors.isEmpty) {
  print("All players registered successfully");
} else {
  errors.forEach((name, error) {
    print("Failed to register $name: $error");
  });
}
```

---

### 7. Find Player by Name

**Method:** `findPlayerByName(String name)`

**Description:** Searches for players by name (partial match, case-insensitive).

**Parameters:**
- `name` (String): The search term

**Returns:** `Future<List<Player>>` - List of matching players

**Usage:**
```dart
final results = await playerService.findPlayerByName("john");
for (final player in results) {
  print(player.name);
}
```

---

### 8. Clear All Players

**Method:** `clearAllPlayers()`

**Description:** Removes all players from the registry. Useful for testing or resetting the app.

**Usage:**
```dart
await playerService.clearAllPlayers();
```

---

## Player Model

The `Player` class has the following properties:

```dart
class Player {
  final String id;           // Unique identifier (auto-generated)
  final String name;         // Player's name
  final DateTime registeredAt; // Registration timestamp
}
```

## Example: Complete Player Registration Flow

```dart
// 1. Load players on app start
await playerService.loadPlayers();

// 2. Add a new player
final error = await playerService.addPlayer("John Doe");
if (error != null) {
  showSnackBar(error);
  return;
}

// 3. Get all players for display
final players = await playerService.getPlayers();
setState(() {
  _playerList = players;
});

// 4. Search for a player
final searchResults = await playerService.findPlayerByName("john");

// 5. Update player name
final updateError = await playerService.updatePlayer(playerId, "John Smith");

// 6. Remove a player
final removeError = await playerService.removePlayer(playerId);
```

## Testing

For unit tests, use the `MockPlayerService` class:

```dart
import 'package:flutter_bball_app/test/mocks/mock_player_service.dart';

final mockService = MockPlayerService();
mockService.setMockPlayers([
  Player(id: "1", name: "Test Player", registeredAt: DateTime.now()),
]);

// Use mockService in your tests
```

## Best Practices

1. **Always handle errors:** All mutating operations return error messages that should be displayed to users.

2. **Load on startup:** Call `loadPlayers()` when the app starts to ensure data is available.

3. **Name validation:** The service automatically trims whitespace and checks for duplicates case-insensitively.

4. **Immutable lists:** `getPlayers()` returns an unmodifiable list to prevent accidental modifications.

5. **Persistent storage:** All changes are automatically saved to disk, so data persists between app sessions.