# Game Timer Service API Documentation

## Overview

The `GameTimerService` is a Flutter service that manages countdown timers for 2-on-2 basketball tournament games. It provides a robust timer implementation with controls for starting, pausing, resuming, and resetting, along with audio cues and real-time updates for UI integration.

## Features

- **Countdown Timer**: Manages game countdown with configurable duration (default: 5 minutes)
- **Timer Controls**: Start, pause, resume, and reset functionality
- **Audio Cues**: Plays audio notification when timer reaches zero
- **Real-time Updates**: Provides both ChangeNotifier and Stream-based updates
- **Completion Callbacks**: Register multiple callbacks for timer completion
- **Robust State Management**: Handles app backgrounding and maintains accurate time

## Installation

The service is already included in the Flutter Basketball App. To use it:

```dart
import 'package:flutter_bball_app/services/game_timer_service.dart';
```

## Basic Usage

### Simple Timer Example

```dart
// Get the singleton instance
final timer = GameTimerService();

// Register a completion callback
timer.onTimerComplete(() {
  print('Game Over!');
});

// Start a 5-minute timer
timer.startTimer(300);

// Check remaining time
print('Time left: ${timer.getTimeRemaining()} seconds');

// Pause the timer
timer.pauseTimer();

// Resume the timer
timer.resumeTimer();

// Reset to 5 minutes
timer.resetTimer(300);
```

### Using with Flutter Widgets

```dart
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameTimerService _timer = GameTimerService();

  @override
  void initState() {
    super.initState();
    _timer.onTimerComplete(_handleGameEnd);
  }

  void _handleGameEnd() {
    // Navigate to game over screen
    Navigator.pushReplacementNamed(context, '/game-over');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _timer,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              'Time: ${formatDuration(_timer.getTimeRemaining())}',
              style: TextStyle(fontSize: 48),
            ),
            ElevatedButton(
              onPressed: _timer.isRunning() 
                  ? _timer.pauseTimer 
                  : () => _timer.startTimer(300),
              child: Text(_timer.isRunning() ? 'Pause' : 'Start'),
            ),
          ],
        );
      },
    );
  }
}
```

## API Reference

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `timerStream` | `Stream<int>` | Real-time stream of remaining seconds |

### Methods

#### `startTimer([int seconds])`
Starts the timer for the specified duration.

**Parameters:**
- `seconds` (optional): Duration in seconds (default: 300)

**Example:**
```dart
timer.startTimer(180); // Start 3-minute timer
timer.startTimer();    // Start with default 5 minutes
```

#### `pauseTimer()`
Pauses the countdown. The timer can be resumed from where it left off.

**Example:**
```dart
timer.pauseTimer();
```

#### `resumeTimer()`
Resumes the countdown from where it was paused.

**Example:**
```dart
timer.resumeTimer();
```

#### `resetTimer([int seconds])`
Resets the timer to the specified duration without starting it.

**Parameters:**
- `seconds` (optional): Duration in seconds (default: 300)

**Example:**
```dart
timer.resetTimer(240); // Reset to 4 minutes
timer.resetTimer();    // Reset to default 5 minutes
```

#### `getTimeRemaining()`
Returns the current time remaining in seconds.

**Returns:** `int` - Remaining seconds

**Example:**
```dart
int timeLeft = timer.getTimeRemaining();
```

#### `isRunning()`
Returns whether the timer is currently running.

**Returns:** `bool` - True if running, false otherwise

**Example:**
```dart
if (timer.isRunning()) {
  print('Game in progress');
}
```

#### `onTimerComplete(Function callback)`
Registers a callback to be called when the timer reaches zero.

**Parameters:**
- `callback`: Function to execute when timer completes

**Example:**
```dart
timer.onTimerComplete(() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Game Over!'),
    ),
  );
});
```

#### `playAudioCue()`
Manually triggers the audio cue (bell sound). This is called automatically when the timer reaches zero.

**Example:**
```dart
await timer.playAudioCue();
```

#### `getElapsedSeconds()`
Returns the elapsed time since the timer started.

**Returns:** `int` - Elapsed seconds

**Example:**
```dart
int elapsed = timer.getElapsedSeconds();
print('Game has been running for $elapsed seconds');
```

#### `getTotalSeconds()`
Returns the total duration set for the timer.

**Returns:** `int` - Total duration in seconds

**Example:**
```dart
int total = timer.getTotalSeconds();
```

#### `clearCallbacks()`
Removes all registered completion callbacks.

**Example:**
```dart
timer.clearCallbacks();
```

#### `removeCallback(Function callback)`
Removes a specific callback.

**Parameters:**
- `callback`: The callback function to remove

**Example:**
```dart
void myCallback() => print('Done');
timer.onTimerComplete(myCallback);
// Later...
timer.removeCallback(myCallback);
```

## Advanced Usage

### Using Stream for Real-time Updates

```dart
StreamBuilder<int>(
  stream: timer.timerStream,
  initialData: timer.getTimeRemaining(),
  builder: (context, snapshot) {
    final seconds = snapshot.data ?? 0;
    return Text(
      formatDuration(seconds),
      style: TextStyle(
        fontSize: 48,
        color: seconds <= 10 ? Colors.red : Colors.white,
      ),
    );
  },
)
```

### Multiple Timers for Tournament

```dart
class TournamentManager {
  final Map<String, GameTimerService> _gameTimers = {};

  void startGame(String courtId, int duration) {
    _gameTimers[courtId] = GameTimerService();
    _gameTimers[courtId]!.startTimer(duration);
  }

  void pauseGame(String courtId) {
    _gameTimers[courtId]?.pauseTimer();
  }

  int? getTimeRemaining(String courtId) {
    return _gameTimers[courtId]?.getTimeRemaining();
  }
}
```

### Custom Timer Widget

See `lib/widgets/game_timer_widget.dart` for example implementations:
- `GameTimerWidget`: Full-featured timer display with controls
- `CompactGameTimerWidget`: Compact timer for app bars

## Testing

The service includes comprehensive unit tests. Run them with:

```bash
flutter test test/services/game_timer_service_test.dart
```

## Best Practices

1. **Singleton Usage**: The service uses a singleton pattern. Always use `GameTimerService()` to get the same instance.

2. **Cleanup**: If using callbacks, remember to clean them up when appropriate:
   ```dart
   @override
   void dispose() {
     timer.clearCallbacks();
     super.dispose();
   }
   ```

3. **State Persistence**: The timer continues running even when the app is backgrounded, ensuring accurate game timing.

4. **UI Updates**: Use either `ChangeNotifier` pattern with `ListenableBuilder` or the `timerStream` for real-time UI updates.

5. **Error Handling**: The service handles edge cases like multiple starts, pausing when already paused, etc.

## Example Game Flow

```dart
class BasketballGame {
  final GameTimerService timer = GameTimerService();
  
  void startGame() {
    // Setup
    timer.onTimerComplete(_endGame);
    
    // Start 5-minute game
    timer.startTimer(300);
    print('Game started!');
  }
  
  void handleTimeout() {
    timer.pauseTimer();
    print('Timeout called');
  }
  
  void resumeAfterTimeout() {
    timer.resumeTimer();
    print('Game resumed');
  }
  
  void _endGame() {
    print('Game over!');
    // Play buzzer sound (handled automatically)
    // Navigate to results screen
  }
}
```

## Troubleshooting

**Timer not updating UI**: Ensure you're using either `ListenableBuilder` or `StreamBuilder` to listen to timer changes.

**Audio not playing**: Check that the device volume is not muted and the app has necessary permissions.

**Timer continues after disposal**: Always reset or pause the timer when disposing of screens that use it.

## Future Enhancements

Potential improvements that could be added:
- Overtime periods
- Warning sounds at specific intervals
- Persistence across app restarts
- Custom audio files for different events
- Integration with game statistics tracking