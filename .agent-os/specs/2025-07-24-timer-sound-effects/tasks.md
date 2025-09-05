# Tasks: Timer Sound Effects

> Status: Planned

## M1: Service & Settings
- [ ] Create `lib/services/sound_effects_service.dart` with `playTimerComplete()`
- [ ] Extend `lib/services/settings_service.dart` with `playTimerSounds`
- [ ] Unit tests: `test/services/sound_effects_service_test.dart`
- [ ] Update settings persistence tests

## M2: UI Integration
- [ ] Add toggle in `lib/screens/settings/settings_screen.dart`
- [ ] Widget test for toggle state and persistence

## M3: Timer Hookup
- [ ] Integrate in `lib/screens/active/widgets/timed_drill_widget.dart`
- [ ] Ensure `CountdownTimerWidget` remains compatible
- [ ] Integration tests for enabled/disabled paths

## M4: Platform Verification
- [ ] Manual Android run – verify immediate playback
- [ ] Manual Web run – verify after user interaction
- [ ] Document caveats in spec

## Documentation
- [ ] Update release notes
- [ ] Confirm Acceptance Criteria in spec are met


