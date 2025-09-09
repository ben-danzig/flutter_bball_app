# Reusable Timer Components

This directory contains reusable timer components that have been extracted from the workout flow to be used across the application.

## Components

### CountdownTimerWidget

A flexible countdown timer widget that can be used for various timing scenarios.

#### Usage Example:

```dart
import 'package:flutter_bball_app/utils/widgets/countdown_timer_widget.dart';

CountdownTimerWidget(
  durationSeconds: 300, // 5 minutes
  onComplete: () {
    // Called when timer reaches zero
    print('Timer completed!');
  },
  onTick: (secondsLeft) {
    // Called every second with remaining time
    print('$secondsLeft seconds left');
  },
  isPaused: false,
  title: 'Workout Timer',
  subtitle: 'Keep going!',
  fontSize: 120,
  textColor: Colors.green,
)
```

#### Parameters:

- `durationSeconds` (required): The total duration in seconds
- `onComplete` (optional): Callback when timer reaches zero
- `onTick` (optional): Callback called every second with remaining seconds
- `onTickSound` (optional): Callback for tick sounds during final 3 seconds (at 3s and 2s remaining)
- `isPaused` (optional): Whether the timer is paused
- `showTapToEdit` (optional): Whether tapping the timer shows edit dialog
- `onTimeEdit` (optional): Callback when time is edited via dialog
- `title` (optional): Title displayed above timer
- `subtitle` (optional): Subtitle displayed below timer
- `fontSize` (optional): Font size for timer display (default: 300)
- `textColor` (optional): Color for timer text (default: white)
- `backgroundColor` (optional): Background color (default: transparent)

### PauseResumeButton

A reusable pause/resume button that can be used with any timer.

#### Usage Example:

```dart
import 'package:flutter_bball_app/utils/widgets/pause_resume_button.dart';

PauseResumeButton(
  isPaused: false,
  onTogglePause: () {
    setState(() {
      isPaused = !isPaused;
    });
  },
  fontSize: 16,
  textColor: Color(0xFF9ca3af),
)
```

#### Parameters:

- `isPaused` (required): Whether the timer is currently paused
- `onTogglePause` (required): Callback to toggle pause state
- `textColor` (optional): Color for button text
- `fontSize` (optional): Font size for button text
- `fontWeight` (optional): Font weight for button text

## Integration Examples

### Game Timer with Pause

```dart
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Pause button at top
          Padding(
            padding: EdgeInsets.all(20.0),
            child: PauseResumeButton(
              isPaused: _isPaused,
              onTogglePause: () {
                setState(() {
                  _isPaused = !_isPaused;
                });
              },
            ),
          ),
          // Timer in center
          Expanded(
            child: CountdownTimerWidget(
              durationSeconds: 300,
              onComplete: () {
                // Handle game end
              },
              isPaused: _isPaused,
              title: 'Game Time!',
              fontSize: 120,
              textColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Migration from Old Timer Logic

The old timer implementations in `TimedDrillWidget` and `GamePrepScreen` have been refactored to use these reusable components. This provides:

1. **Consistency**: All timers now behave the same way
2. **Maintainability**: Timer logic is centralized
3. **Flexibility**: Easy to customize for different use cases
4. **Reusability**: Can be used in new features without duplicating code 