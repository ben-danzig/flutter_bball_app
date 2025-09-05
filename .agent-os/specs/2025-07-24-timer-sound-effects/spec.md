# Spec Requirements Document

> Spec: Timer Sound Effects
> Created: 2025-07-24
> Status: Planning

## Overview

Add audio notification when drill timers complete to provide clear feedback to users during timed drills. This feature will play a sound effect when the countdown timer reaches zero, helping users stay focused on their training without constantly watching the screen.

## User Stories

### Audio Feedback for Timer Completion

As a basketball player using timed drills, I want to hear a sound when the timer completes, so that I can focus on my training execution without constantly looking at my phone screen to check the timer.

**Detailed Workflow:**
1. User starts a workout containing TIMED drills
2. Timer begins counting down from the specified duration
3. User performs the drill while listening for audio cues
4. When timer reaches zero, a sound effect plays automatically
5. User receives immediate audio feedback that the drill time is complete
6. User can transition to the next drill without interrupting their flow

### Settings Control for Timer Sounds

As a user, I want to control whether timer completion sounds play, so that I can customize the audio experience based on my training environment and preferences.

**Detailed Workflow:**
1. User navigates to Settings screen
2. User sees a toggle option for "Timer Sound Effects"
3. User can enable or disable the sound based on their preference
4. Setting is persisted and respected during all future workouts

## Spec Scope

1. **Timer Completion Sound Effect** - Play audio when TIMED drill countdown reaches zero
2. **User Preference Setting** - Add toggle control in settings to enable/disable timer sounds
3. **Audio Asset Integration** - Use existing audio files (timer-end.mp3, buzzer.mp3) for the sound effect
4. **Cross-Platform Compatibility** - Ensure sound works on Web and Android platforms
5. **Settings Persistence** - Save user's timer sound preference locally and restore on app restart

## Out of Scope

- Sound effects for other drill types (REP_BASED, MAKE_TARGET_TIMED) - these have different completion mechanics
- Custom sound selection - will use predetermined audio file
- Volume control specific to timer sounds - will use system volume
- Visual effects or animations accompanying the sound

## Expected Deliverable

1. **Timer Sound Plays on Completion** - When a TIMED drill countdown reaches zero, an audio effect plays automatically
2. **Settings Toggle Available** - Users can find and toggle "Timer Sound Effects" option in the Settings screen
3. **Preference Persistence** - User's timer sound preference is saved and restored between app sessions 

## Acceptance Criteria

- [ ] **Timer completion audio**: For TIMED drills, a sound plays within 150ms of the countdown reaching zero.
- [ ] **Settings default**: "Timer Sound Effects" is enabled by default for first-time users.
- [ ] **Settings persistence**: Toggling the setting is persisted and restored on app restart.
- [ ] **Respect preference**: When disabled, no timer completion sound plays.
- [ ] **Non-blocking**: Sound playback does not block drill completion or navigation.
- [ ] **Cross-platform**: Behavior verified on Android and Web without runtime errors.
- [ ] **Asset usage**: Uses `assets/timer-end.mp3` by default, with `assets/buzzer.mp3` available as fallback if needed.

## Milestones & Tasks

### M1: Service & Settings (1–2 days)
- [ ] Create `SoundEffectsService` with `playTimerComplete()` using `audioplayers`.
- [ ] Extend `SettingsService` with `playTimerSounds` (default true) and persistence.
- [ ] Unit tests for service and settings persistence.

### M2: UI Integration (0.5–1 day)
- [ ] Add "Timer Sound Effects" toggle to `SettingsScreen` under Audio Cues.
- [ ] Wire toggle to `SettingsService` and verify state updates.
- [ ] Widget/integration tests for UI toggle behavior.

### M3: Timer Hookup (1 day)
- [ ] Trigger sound on TIMED drill completion in `TimedDrillWidget`.
- [ ] Ensure `CountdownTimerWidget` API remains backward compatible.
- [ ] Integration tests verifying sound/no-sound paths.

### M4: Platform Verification (0.5 day)
- [ ] Manual verification on Android device/emulator.
- [ ] Manual verification on Web (gesture-unlocked audio context).
- [ ] Document any platform-specific caveats.

## Risks & Mitigations

- **Web autoplay restrictions**: Browsers may block playback without prior user interaction.
  - Mitigation: Ensure audio context is unlocked via prior tap (starting a workout), and document behavior.
- **Audio latency on cold start**: First playback may be delayed.
  - Mitigation: Initialize the `AudioPlayer` early (app startup or first workout screen) to warm up.
- **Conflicts with TTS**: Overlapping audio with text-to-speech could reduce clarity.
  - Mitigation: Use separate service; keep short, single-shot effect and do not await completion.

## Dependencies

- `audioplayers: ^5.2.1` (already in `pubspec.yaml`)
- Assets present: `assets/timer-end.mp3`, `assets/buzzer.mp3`

## Rollout & Verification

- Smoke test on Android and Web.
- Confirm acceptance criteria via automated tests plus manual checks.
- Add release notes entry: "Timer completion sound with settings toggle."

## Open Questions

- Do we want a vibration/haptic cue alongside audio on supported devices? (Future scope)
- Should we add a per-workout override for timer sounds, or keep it global-only for now?
- Any need for a short cooldown to avoid overlapping sounds if multiple timers end quickly?