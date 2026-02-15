# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-07-24-timer-sound-effects/spec.md

> Created: 2025-07-24
> Version: 1.0.0

## Technical Requirements

- **Sound Effect Playback**: Integrate with existing AudioPlayers package to play sound files when timer completes
- **Settings Integration**: Extend SettingsService to include timer sound preference with local persistence
- **UI Integration**: Add timer sound toggle to existing Settings screen interface
- **Timer Integration**: Modify timer completion callback to trigger sound effect
- **Cross-Platform Support**: Ensure sound playback works consistently on Web and Android platforms
- **Performance**: Sound should play immediately without noticeable delay when timer reaches zero

## Approach Options

**Option A: Extend AudioService with Sound Effects**
- Pros: Single audio service, consistent API, easy to test
- Cons: Mixing TTS and sound effect concerns in one service

**Option B: Create Separate SoundEffectsService** (Selected)
- Pros: Clear separation of concerns, focused responsibility, easier to maintain
- Cons: Additional service to manage, slight increase in complexity

**Option C: Inline Sound Effect in Timer Widget**
- Pros: Simple implementation, direct control
- Cons: Tight coupling, harder to test, violates separation of concerns

**Rationale:** Option B provides the best balance of maintainability and separation of concerns. A dedicated SoundEffectsService can handle all non-TTS audio needs and can be easily extended for future sound effects (workout completion, achievement unlocks, etc.).

## External Dependencies

- **audioplayers (5.2.1)** - Already included for sound effect playback
- **Justification:** Existing dependency that provides reliable cross-platform audio playback capabilities

## Implementation Details

### 1. Create SoundEffectsService

```dart
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playTimerComplete() async {
    try {
      // Keep non-blocking; do not await completion beyond start
      await _audioPlayer.play(AssetSource('timer-end.mp3'));
    } catch (_) {
      // Fallback to buzzer if default asset fails
      try { await _audioPlayer.play(AssetSource('buzzer.mp3')); } catch (_) {}
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
```

### 2. Extend SettingsService

- Add `bool _playTimerSounds = true` field
- Add getter `bool get playTimerSounds`
- Add setter method `Future<void> setPlayTimerSounds(bool value)` with persistence
- Update `_loadSettings()` and `_saveSettings()` methods to handle new field

Notes:
- Persist alongside existing announce settings in the same JSON file.
- Notify listeners on change.

### 3. Update Settings Screen UI

- Add new ListTile with Switch for "Timer Sound Effects"
- Connect to SettingsService.playTimerSounds
- Follow existing UI patterns and styling

### 4. Integrate Sound Effect in Timer Completion

- Modify `TimedDrillWidget._onTimerComplete()` to check settings and play sound
- Add SoundEffectsService dependency injection through Provider or direct instantiation
- Ensure sound plays before logging drill result and advancing to next drill

Dependency Injection:
- Provide `SoundEffectsService` at app level using `Provider` for easy access in widgets.

### 5. Timer Widget Integration

- Update `CountdownTimerWidget` to accept optional sound completion callback
- Maintain backward compatibility for other timer usages
- Keep sound logic in consuming widget rather than generic timer component

### 6. Performance & Latency
- Initialize `AudioPlayer` on first use or early in app lifecycle to reduce first-play latency.
- Keep audio files as small as practical; current assets are acceptable.

### 7. Web Considerations
- Ensure playback is triggered after a user gesture (e.g., starting a workout) to satisfy autoplay policies.
- If blocked, fail silently and continue workout flow.

## File Changes Required

1. **Create**: `lib/services/sound_effects_service.dart`
2. **Modify**: `lib/services/settings_service.dart`
3. **Modify**: `lib/screens/settings/settings_screen.dart`
4. **Modify**: `lib/screens/active/widgets/timed_drill_widget.dart`
5. **Create**: `test/services/sound_effects_service_test.dart`
6. **Modify**: `test/services/settings_service_test.dart`
7. **Modify**: `lib/screens/settings/settings_screen.dart` (add toggle)

## Error Handling

- Graceful degradation if audio file fails to load
- Silent failure if sound playback encounters errors (don't interrupt workout flow)
- Proper disposal of audio resources to prevent memory leaks
- Platform-specific audio issues should not crash the app 