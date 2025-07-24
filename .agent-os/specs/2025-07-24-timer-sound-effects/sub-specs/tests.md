# Tests Specification

This is the tests coverage details for the spec detailed in @.agent-os/specs/2025-07-24-timer-sound-effects/spec.md

> Created: 2025-07-24
> Version: 1.0.0

## Test Coverage

### Unit Tests

**SoundEffectsService**
- Should create singleton instance correctly
- Should play timer completion sound when playTimerComplete() is called
- Should handle audio player errors gracefully without throwing exceptions
- Should dispose audio player resources properly

**SettingsService (Extended)**
- Should default playTimerSounds to true for new installations
- Should save and load playTimerSounds setting correctly from local storage
- Should notify listeners when playTimerSounds setting changes
- Should handle JSON serialization/deserialization of playTimerSounds field

### Integration Tests

**Timer Sound Integration**
- Should play sound when TIMED drill timer completes and setting is enabled
- Should not play sound when TIMED drill timer completes and setting is disabled
- Should not interfere with existing drill progression and logging functionality
- Should maintain sound preference across app restarts

**Settings Screen Integration**
- Should display timer sound toggle in settings screen
- Should update SettingsService when user toggles timer sound setting
- Should reflect current timer sound preference in UI toggle state
- Should persist toggle state changes immediately

### Widget Tests

**TimedDrillWidget (Modified)**
- Should call SoundEffectsService.playTimerComplete() when timer completes and setting enabled
- Should not call sound service when timer completes and setting disabled
- Should continue normal drill completion flow regardless of sound setting
- Should handle sound service errors without affecting timer completion

**Settings Screen (Modified)**
- Should render timer sound toggle switch correctly
- Should respond to toggle switch interactions
- Should display correct toggle state based on SettingsService value
- Should maintain existing settings functionality while adding new toggle

### Feature Tests

**End-to-End Timer Sound Workflow**
- Start workout with TIMED drill, enable timer sounds, verify sound plays on completion
- Start workout with TIMED drill, disable timer sounds, verify no sound plays
- Toggle timer sound setting mid-workout, verify setting takes effect on next drill
- Complete multiple TIMED drills with sounds enabled, verify consistent behavior

### Mocking Requirements

- **AudioPlayer:** Mock the audioplayers package to verify play() method calls without actual audio
- **Platform Audio:** Mock platform-specific audio capabilities for consistent testing across environments
- **Local Storage:** Mock file system operations for settings persistence testing
- **Timer Completion:** Mock timer advancement to trigger completion events predictably

## Test Strategy

### Unit Test Implementation
- Use Flutter's built-in testing framework with testWidgets() for widget tests
- Mock AudioPlayer using Mockito to verify method calls without playing actual sounds
- Test settings persistence using temporary test directories

### Integration Test Approach
- Use Flutter integration tests to verify cross-component behavior
- Test actual audio playback on target devices (Android, Web) for manual verification
- Validate settings persistence across app lifecycle events

### Performance Testing
- Measure audio playback latency to ensure immediate response
- Test memory usage to verify proper audio resource disposal
- Validate smooth timer progression with audio integration

### Cross-Platform Testing
- Test audio playback specifically on Web platform (different audio handling)
- Verify Android audio playback with various system volume settings
- Test graceful degradation when audio permissions are denied

## Testing Edge Cases

- Timer completion with no internet connection (offline audio assets)
- Rapid timer completion events (multiple timers finishing quickly)
- Audio player already in use by other parts of the app
- Settings change during active timer countdown
- App backgrounding during timer completion with sound 