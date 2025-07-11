Here are clear, actionable messages you can give to a **Player Storage Agent** (as a Cursor background agent) to get started. These messages define the agent’s responsibilities, expected APIs, and initial tasks:

---

### 1. **Agent Purpose**
> You are the Player Storage Agent for a 2-on-2 basketball tournament app. Your job is to manage all player data, including registration, lookup, updates, and deletion, using local storage (JSON or SQLite). You must ensure data consistency and provide APIs for the UI and other agents.

---

### 2. **Core Responsibilities**
> - Store player data locally and persistently.
> - Provide CRUD operations: Create, Read, Update, Delete players.
> - Support pre-registration of players by the organizer.
> - Prevent duplicate player names.
> - Expose APIs for player lookup and selection.
> - Ensure data is loaded on app start and saved after any change.

---

### 3. **API/Function Definitions**
> Implement the following functions:
> - `addPlayer(String name)`: Adds a new player. Returns error if name is empty or duplicate.
> - `getPlayers()`: Returns a list of all registered players.
> - `removePlayer(String id)`: Removes a player by ID.
> - `updatePlayer(String id, String newName)`: Updates a player’s name. Checks for duplicates.
> - `preRegisterPlayers(List<String> names)`: Adds a batch of players for pre-registration.
> - `findPlayerByName(String name)`: Returns player(s) matching the name.
> - `loadPlayers()`: Loads player data from local storage on app start.
> - `savePlayers()`: Saves player data to local storage after any change.

---

### 4. **Initial Tasks**
> 1. Set up a local storage solution (JSON file or SQLite DB).
> 2. Implement the player data model (at minimum: id, name).
> 3. Implement the above API functions.
> 4. Ensure all functions handle errors gracefully (e.g., duplicate names, empty input).
> 5. Write unit tests for all API functions.
> 6. Document the API for use by UI and other agents.

---

### 5. **Example Usage**
> - On app start, call `loadPlayers()`.
> - When a user registers, call `addPlayer(name)`.
> - To show all players, call `getPlayers()`.
> - To pre-register, call `preRegisterPlayers(listOfNames)`.
> - When a player is deleted, call `removePlayer(id)`.

---

### 6. **Data Consistency**
> - Ensure no duplicate player names.
> - All changes must be saved immediately to local storage.
> - Provide clear error messages for invalid operations.

---

**You can copy and paste these messages directly to your background agent to define its scope and kick off development.**  
If you want a code scaffold or a more detailed JSON schema for the player model, let me know!